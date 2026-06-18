import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LlmService {
  late final GenerativeModel _model;

  LlmService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(model: "gemini-2.5-flash", apiKey: apiKey);
  }

  Future<String> identifyUserIntent(List<String> availableDocuments, String userMessage) async {
    final jsonLog = jsonEncode({
      "availableDocuments": availableDocuments,
      "userMessage": userMessage,
    });

    debugPrint("[INFO] LlmService.identifyUserIntent Called with: \n$jsonLog");

    try {
      final data = await _model.generateContent(
        [
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
              "}\n\n"
              "User request: $userMessage"
          )
        ],
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final String response = data.text ?? "{}";

      // For debugging
      debugPrint("[INFO] LlmService.identifyUserIntent responds with $response");
      return response;

    } catch (e, stackTrace) {
      debugPrint("[ERROR] Failed to identify user intent: $e");
      debugPrint(stackTrace.toString());
      return "{}";
    }
  }

  Future<String> generateDocumentResponse(bool hasDocs, String intent, String document, String requirements) async {
    final jsonLog = jsonEncode({
      "info": "LlmService.generateDocumentResponse called",
      "intent": intent,
      "requirements": requirements,
      "document": document,
    });

    debugPrint("[INFO] LlmService.generateDocumentResponse called with: \n$jsonLog");

    try {
      final prompt = hasDocs
          ? """
            Based on the user's intent: "$intent", and the document they need: "$document",
            the required documents are: $requirements.

            Write a friendly answer listing these.
            """
          : """
            The document "$document" is not on the list.
            Write a friendly response saying this.
            """;

      final data = await _model.generateContent([
        Content.text(prompt)
      ]);

      final String response = data.text ?? "Sorry, I couldn't process that.";
      return response;

    } catch (e, stackTrace) {
      debugPrint("[ERROR] Failed to generate document response: $e");
      debugPrint(stackTrace.toString());
      return "Sorry, an error occurred while processing your request.";
    }
  }
}