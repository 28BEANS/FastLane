import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotController with ChangeNotifier {
  
  final List<Map<String, String>> messages = [];

  late final GenerativeModel _model;

  ChatbotController() {
    final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';  
    _model = GenerativeModel(
      model:"gemini-2.5-flash",
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
          "You are BINO, a government service assistant. Answer clearly.\n"
          "User request: $userMessage",
        )
      ]);

      final botReply = response.text ?? "Sorry, I couldn't process that.";

      messages.insert(0, {"role": "bot", "text": botReply});
    } catch (e) {
      messages.insert(0, {"role": "bot", "text": "Error: $e"});
    }

    notifyListeners();
  }
}
