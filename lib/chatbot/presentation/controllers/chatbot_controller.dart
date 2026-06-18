import 'package:flutter/foundation.dart';
import '../utils/json_convert.dart';
import '../../data/chatbot_service.dart';
import 'package:fast_lane/core/constants/document_constants.dart';
import '../../data/llm_service.dart';
import '../../../checklist/presentation/controllers/checklist_controller.dart';

class ChatbotController with ChangeNotifier {
  final availableDocuments = DocumentType.values.map((d) => d.name).toList();
  final List<Map<String, String>> messages = [];
  late final LlmService _llm;

  List<String> lastSuggestedRequirements = [];
  late ChecklistController checklistController;

  String? lastSuggestedTaskName;

  ChatbotController({required this.checklistController}) {
    _llm = LlmService();
  }

  /// Update checklist controller reference (for ProxyProvider)
  void updateChecklistController(ChecklistController controller) {
    checklistController = controller;
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    messages.insert(0, {"role": "user", "text": userMessage});
    notifyListeners();

    try {
      final userIntent = await _llm.identifyUserIntent(availableDocuments, userMessage);
      final request = parseLLMResponse(userIntent);

      // Save document name as task name
      lastSuggestedTaskName = request.documents;

      final documentRequirements = await fetchDocumentRequirements(request.documents);
      lastSuggestedRequirements = documentRequirements;
      notifyListeners();

      final hasDocs = documentRequirements.isNotEmpty;

      final documentResponse = await _llm.generateDocumentResponse(
          hasDocs,
          request.intent,
          request.documents,
          documentRequirements.join(", ")
      );

      messages.insert(0, {"role": "bot", "text": documentResponse});
    } catch (e) {
      messages.insert(0, {"role": "bot", "text": "Error: $e"});
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
