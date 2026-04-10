import 'package:flutter/foundation.dart';
import '../utils/json_convert.dart';
import '../../data/chatbot_service.dart';
import 'package:fast_lane/core/constants/document_constants.dart';
import '../../data/llm_service.dart';
import '../../../checklist/presentation/controllers/checklist_controller.dart';
import '../../data/embedding_service.dart';
import '../../data/vector_store.dart';
import '../../data/knowledge_base_service.dart';

class ChatbotController with ChangeNotifier {
  final availableDocuments = DocumentType.values.map((d) => d.name).toList();
  final List<Map<String, String>> messages = [];
  late final LlmService _llm;
  final VectorStore _vectorStore;

  List<String> lastSuggestedRequirements = [];
  late ChecklistController checklistController;
  String? lastSuggestedTaskName;
  bool _isRAGInitialized = false;
  bool isChecklistCollapsed = true;
  bool isLoading = false;

  ChatbotController({required ChecklistController checklistController}) 
    : _vectorStore = VectorStore(
        embeddingService: EmbeddingService(),
        knowledgeBaseService: KnowledgeBaseService(),
      ) {
    _llm = LlmService();
    this.checklistController = checklistController;
  }

  void toggleChecklistCollapse() {
    isChecklistCollapsed = !isChecklistCollapsed;
    notifyListeners();
  }

  void updateChecklistController(ChecklistController controller) {
    checklistController = controller;
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    messages.insert(0, {"role": "user", "text": userMessage});
    isLoading = true;
    notifyListeners();

    try {
      // 1. Lazy Initialize RAG
      if (!_isRAGInitialized) {
        await _vectorStore.initialize();
        _isRAGInitialized = true;
      }

      // 2. Intent Detection
      final userIntent = await _llm.identifyUserIntent(availableDocuments, userMessage);
      final request = parseLLMResponse(userIntent);
      lastSuggestedTaskName = request.documents;

      // 3. Fetch Core Requirements
      final documentRequirements = await fetchDocumentRequirements(request.documents);
      lastSuggestedRequirements = documentRequirements;
      final hasDocs = documentRequirements.isNotEmpty;

      // 4. RAG Retrieval (VectorStore handles embedding and search internally)
      final results = await _vectorStore.search(userMessage, topK: 3);
      
      final ragContext = results.isEmpty 
          ? "No specific additional knowledge found." 
          : results.map((c) => "[${c.category}] ${c.title}: ${c.content}").join("\n\n");

      // 5. Generate Response
      final response = await _llm.generateRAGResponse(
        hasDocs,
        request.intent,
        request.documents,
        documentRequirements.join(", "),
        ragContext,
      );

      messages.insert(0, {"role": "bot", "text": response});
    } catch (e) {
      print("[ERROR] ChatbotController.sendMessage: $e");
      messages.insert(0, {"role": "bot", "text": "Error: $e"});
    }

    isLoading = false;
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
