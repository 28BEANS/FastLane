import 'package:flutter/foundation.dart';
import '../utils/json_convert.dart'; // Import your LLM response parser
import '../../data/chatbot_service.dart';
import 'package:fast_lane/core/constants/document_constants.dart';
import '../../data/llm_service.dart';

class ChatbotController with ChangeNotifier {

  final availableDocuments = DocumentType.values.map((d) => d.name).toList();

  final List<Map<String, String>> messages = [];
  late final LlmService _llm;

  List<String> lastSuggestedRequirements = [];
  List<String> userChecklist = [];

  ChatbotController() {
    _llm = LlmService();
  }

  // Send message method
  Future<void> sendMessage(String userMessage) async {

    if (userMessage.trim().isEmpty) return;

    messages.insert(0, {"role": "user", "text": userMessage});
    notifyListeners();

    try {

      // LLM Analyzing user Intent
      final userIntent = await _llm.identifyUserIntent(availableDocuments, userMessage);
      final UserRequest request = parseLLMResponse(userIntent);

      // Additional Context for LLM
      final List<String> documentRequirements = await fetchDocumentRequirements(request.documents);
      final bool hasDocs = documentRequirements.isNotEmpty;

      // LLM Response
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

  // ---------------------- CHECKLIST ACTIONS ----------------------

  void addToChecklist() {
    userChecklist.addAll(lastSuggestedRequirements);
    lastSuggestedRequirements = [];
    notifyListeners();
  }

  void clearSuggestion() {
    lastSuggestedRequirements = [];
    notifyListeners();
  }
}