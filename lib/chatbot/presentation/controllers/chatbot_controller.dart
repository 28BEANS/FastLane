import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/json_convert.dart';
import '../../data/chatbot_service.dart';

class ChatbotController with ChangeNotifier {
  final List<String> availableDocuments = [
    "BirthCert",
    "Passport",
    "DriverLicense",
    "NationalID",
    "SeniorCitizen",
    "SchoolID",
    "CertificateOfRegistration_SchoolID"
  ];

  final List<Map<String, String>> messages = [];

  // NEW: Checklist state
  List<String> lastSuggestedRequirements = [];
  List<String> userChecklist = [];

  late final GenerativeModel _model;

  ChatbotController() {
    final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: "gemini-2.5-flash",
      apiKey: apiKey,
    );
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    // Add user message
    messages.insert(0, {"role": "user", "text": userMessage});
    notifyListeners();

    try {
      // ----------------- FIRST LLM CALL -----------------
      final response = await _model.generateContent([
        Content.text(
          "You are Juan, a government service assistant.\n"
          "Task: Determine the user's intent and which single government document they need.\n\n"
          "Available documents: ${availableDocuments.join(', ')}\n\n"
          "Rules:\n"
          "1. Analyze the user's message.\n"
          "2. If it clearly matches one document, return that document.\n"
          "3. If it does NOT match any document, return null.\n"
          "4. OUTPUT ONLY JSON in EXACTLY this format (nothing else):\n"
          "{\n"
          "  \"user_intent\": \"<DocumentName from the list OR null>\"\n"
          "}\n"
          "5. Do NOT include any text, Markdown, code blocks, explanations, or extra characters.\n"
          "6. Do NOT include quotes around the JSON keys or values except as shown above.\n\n"
          "If you are tempted to add extra text, ignore it. ONLY return the valid JSON object.\n\n"
          "User request: $userMessage"
        )
      ]);

      final String botReply = response.text ?? "Sorry, I couldn't process that.";
      final UserRequest request = parseLLMResponse(botReply);

      // ----------------- DOCUMENT REQUIREMENTS -----------------
      final List<String> documentRequirements =
          request.documents != null
              ? await fetchDocumentRequirements(request.documents)
              : [];

      // Store suggestion for UI confirmation
      lastSuggestedRequirements = documentRequirements;
      notifyListeners();

      // ----------------- SECOND LLM CALL (Friendly response) -----------------
      final bool hasDocs = documentRequirements.isNotEmpty;

      final prompt = hasDocs
          ? """
            Based on the user's intent: "${request.intent}", and the document they need: "${request.documents}",
            the required documents are: ${documentRequirements.join(', ')}.

            Write a friendly answer listing these.
            """
                      : """
            The document "${request.documents}" is not on the list.
            Write a friendly response saying this.
            """;

      final anotherResponse = await _model.generateContent([
        Content.text(prompt),
      ]);

      final String anotherBotReply =
          anotherResponse.text ?? "Sorry, I couldn't process that.";

      messages.insert(0, {"role": "bot", "text": anotherBotReply});
    } catch (e) {
      print("kline");
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
