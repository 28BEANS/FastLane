import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LlmService {
  late final GenerativeModel _model;

  LlmService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(model: "gemini-2.5-flash", apiKey: apiKey);
  }

  Future<String>  identifyUserIntent(availableDocuments, userMessage) async {

    String jsonLog = '''
    {
      "availableDocuments": ${availableDocuments.map((doc) => '"$doc"').toList()},
      "userMessage": "$userMessage"
    }
    ''';

    print("[INFO] LlmService.identifyUserIntent Called with: \n$jsonLog");

    try {

      final data = await _model.generateContent([

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

      final String response = data.text ?? "Sorry, I couldn't process that.";

      // For debugging
      print("[INFO] LlmService.identifyUserIntent responds with $response");
      return response;

    } catch (e, stackTrace) {
      print("[ERROR] Failed to identify user intent: $e");
      print(stackTrace);
      return "Sorry, an error occurred while processing your request.";
    }

  }

  Future<String> generateDocumentResponse(hasDocs, intent, document, requirements) async {

    String jsonLog = '''
    {
      "info": "LlmService.generateDocumentResponse called",
      "intent": "$intent",
      "requirements": "$requirements",
      "document": "$document"
    }
    ''';

    print("[INFO] LlmService.generateDocumentResponse called with: \n$jsonLog");

    try {

      final prompt = hasDocs
          ? """
            Based on the user's intent: "${intent}", and the document they need: "${document}",
            the required documents are: ${requirements}.

            Write a friendly answer listing these.
            """
          : """
            The document "${document}" is not on the list.
            Write a friendly response saying this.
            """;

      final data = await _model.generateContent([
        Content.text(prompt)
      ]);

      final String response = data.text ?? "Sorry, I couldn't process that.";
      return response;

    } catch (e, stackTrace) {
      print("[ERROR] Failed to generate document response: $e");
      print(stackTrace);
      return "Sorry, an error occurred while processing your request.";
    }
  }

}