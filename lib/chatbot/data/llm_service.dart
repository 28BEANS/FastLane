import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LlmService {
  late final GenerativeModel _model;

  LlmService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    // User requested gemini-2.5-flash for speed
    _model = GenerativeModel(model: "gemini-2.0-flash", apiKey: apiKey);
  }

  Future<String> identifyUserIntent(List<String> availableDocuments, String userMessage) async {
    try {
      final prompt = """
        You are Juan, a government service assistant.
        Task: Determine the user's intent and which single government document they need.

        Available documents: ${availableDocuments.join(', ')}

        Rules:
        1. Analyze the user's message.
        2. If it clearly matches one document, return that document.
        3. If it does NOT match any document, return null.
        4. OUTPUT ONLY JSON in EXACTLY this format:
        {
          "user_intent": "<DocumentName from the list OR null>"
        }
        5. Do NOT include any text, Markdown, code blocks, or extra characters.

        User request: $userMessage
        """;

      final data = await _model.generateContent([Content.text(prompt)]);
      return data.text ?? "null";
    } catch (e) {
      print("[ERROR] Failed to identify user intent: $e");
      return "{\"user_intent\": null}";
    }
  }

  Future<String> generateDocumentResponse(bool hasDocs, String intent, String document, String requirements) async {
    try {
      final prompt = hasDocs
          ? "Based on the user's intent: \"$intent\", and the document they need: \"$document\", the required documents are: $requirements. Write a friendly answer listing these."
          : "The document \"$document\" is not on the list. Write a friendly response saying this.";

      final data = await _model.generateContent([Content.text(prompt)]);
      return data.text ?? "Sorry, I couldn't process that.";
    } catch (e) {
      print("[ERROR] Failed to generate document response: $e");
      return "Sorry, an error occurred while processing your request.";
    }
  }

  Future<String> generateRAGResponse(bool hasDocs, String intent, String document, String requirements, String ragContext) async {
    try {
      final prompt = hasDocs
          ? """
            You are BINO, a helpful government service assistant.
            
            USER INTENT: $intent
            TARGET DOCUMENT: $document
            CORE REQUIREMENTS: $requirements
            
            ADDITIONAL KNOWLEDGE:
            $ragContext
            
            TASK:
            Provide a detailed and friendly response to the user. 
            - Mention the requirements clearly.
            - Use the "ADDITIONAL KNOWLEDGE" to provide extra details like fees, steps, office locations, or tips if relevant.
            - Keep the tone helpful and professional.
            """
          : """
            The user is asking about $document ($intent), but we don't have that in our primary requirements list.
            
            ADDITIONAL KNOWLEDGE FOUND:
            $ragContext
            
            TASK:
            Use the "ADDITIONAL KNOWLEDGE" above to provide as much helpful information as possible about $document.
            If no specific knowledge is found, politely explain that we don't have full info yet.
            """;

      final data = await _model.generateContent([Content.text(prompt)]);
      return data.text ?? "Sorry, I couldn't process that.";
    } catch (e) {
      print("[ERROR] Failed to generate RAG response: $e");
      return "Sorry, an error occurred while generating the detailed response.";
    }
  }
}