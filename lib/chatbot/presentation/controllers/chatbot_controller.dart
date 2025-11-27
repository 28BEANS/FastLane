import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/json_convert.dart'; // Import your LLM response parser
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

    messages.insert(0, {"role": "user", "text": userMessage});
    notifyListeners();

    try {
      final response = await _model.generateContent([
        Content.text(
          "You are Juan, a government service assistant.\n"
          "Task: Determine the user's intent and which single government document they need.\n"
          "Use ONLY the following available documents: ${availableDocuments.join(', ')}.\n\n"
          "Instructions:\n"
          "1. Analyze the user's message to determine their intent.\n"
          "2. OUTPUT STRICT JSON ONLY, with ONE key-value pair:\n"
          "   { \"user_intent\": \"DocumentName\" }\n"
          "   - The key \"user_intent\" should be a short description of what the user wants.\n"
          "   - The value should be exactly one document from the available list.\n"
          "3. If no document matches, return null as the value.\n"
          "4. DO NOT include any text, Markdown formatting, or explanations.\n\n"
          "User request: $userMessage"
        )
      ]);


      final String botReply = response.text ?? "Sorry, I couldn't process that.";
      final UserRequest request = parseLLMResponse(botReply);

      final List<String> documentRequirements = await fetchDocumentRequirements(request.documents);

      final anotherResponse = await _model.generateContent([
        Content.text(
          "Based on the user's intent: \"${request.intent}\", and the document(s) they need: \"${request.documents}\", "
          "the required documents are: ${documentRequirements.isNotEmpty ? documentRequirements.join(', ') : 'None'}.\n\n"
          "Provide a friendly response to the user listing the required documents."
        )
      ]);

      final String anotherBotReply = anotherResponse.text ?? "Sorry, I couldn't process that.";

      messages.insert(0, {"role": "bot", "text": anotherBotReply});
    } catch (e) {
      messages.insert(0, {"role": "bot", "text": "Error: $e"});
    }

    notifyListeners();
  }
}
