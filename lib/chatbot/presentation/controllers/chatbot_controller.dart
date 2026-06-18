import 'package:flutter/foundation.dart';
import '../utils/json_convert.dart';
import '../../data/chatbot_service.dart';
import 'package:fast_lane/core/constants/document_constants.dart';
import '../../data/llm_service.dart';
import '../../data/local_intent_matcher.dart';
import '../../../checklist/presentation/controllers/checklist_controller.dart';

class ChatbotController with ChangeNotifier {
  final availableDocuments = DocumentType.values.map((d) => d.name).toList();
  final List<Map<String, String>> messages = [];
  late final LlmService _llm;

  List<String> lastSuggestedRequirements = [];
  late ChecklistController checklistController;

  String? lastSuggestedTaskName;

  // Track whether the last response was generated offline
  bool isOfflineMode = false;

  ChatbotController({required this.checklistController}) {
    _llm = LlmService();
  }

  /// Update checklist controller reference (for ProxyProvider)
  void updateChecklistController(ChecklistController controller) {
    checklistController = controller;
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    messages.insert(0, {'role': 'user', 'text': userMessage});
    notifyListeners();

    try {
      // Step 1: Identify intent — tries Gemini, falls back to local matcher
      final result = await _llm.identifyUserIntent(availableDocuments, userMessage);
      isOfflineMode = result.isOffline;

      List<String> documentRequirements = [];
      String? documentName;

      if (result.isOffline && result.matchedDocument != null) {
        // ── Fully offline path ─────────────────────────────────────────────
        documentName = result.matchedDocument;
        documentRequirements = LocalIntentMatcher.getOfflineRequirements(documentName!);
        lastSuggestedTaskName = documentName;
        lastSuggestedRequirements = documentRequirements;
        notifyListeners();

        final offlineReply = LocalIntentMatcher.buildOfflineResponse(
          documentName: documentName,
          requirements: documentRequirements,
        );

        messages.insert(0, {
          'role': 'bot',
          'text': offlineReply,
          'offline': 'true',
        });
      } else if (result.isOffline && result.matchedDocument == null) {
        // ── Offline, no match ──────────────────────────────────────────────
        messages.insert(0, {
          'role': 'bot',
          'text': "⚠️ I'm currently offline and couldn't identify the document you're asking about. "
              "Please check your internet connection and try again, or describe the document more specifically.",
          'offline': 'true',
        });
      } else {
        // ── Online path — parse Gemini JSON ───────────────────────────────
        final request = parseLLMResponse(result.rawJson);
        documentName = request.documents;
        lastSuggestedTaskName = documentName;

        // Fetch from Firestore (cached after first call)
        documentRequirements = await fetchDocumentRequirements(documentName);
        lastSuggestedRequirements = documentRequirements;
        notifyListeners();

        final hasDocs = documentRequirements.isNotEmpty;
        final documentResponse = await _llm.generateDocumentResponse(
          hasDocs: hasDocs,
          intent: request.intent,
          document: documentName,
          requirements: documentRequirements,
          isOffline: false,
        );

        messages.insert(0, {'role': 'bot', 'text': documentResponse});
      }
    } catch (e) {
      debugPrint('[ChatbotController] sendMessage error: $e');
      messages.insert(0, {
        'role': 'bot',
        'text': '❌ Something went wrong. Please try again.',
      });
    }

    notifyListeners();
  }

  void clearSuggestion() {
    lastSuggestedRequirements = [];
    lastSuggestedTaskName = null;
    notifyListeners();
  }

  void confirmChecklistTask() {
    if (lastSuggestedRequirements.isNotEmpty && lastSuggestedTaskName != null) {
      checklistController.addTask(lastSuggestedTaskName!, lastSuggestedRequirements);
      lastSuggestedRequirements = [];
      lastSuggestedTaskName = null;
      notifyListeners();
    }
  }
}
