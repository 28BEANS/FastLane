import 'dart:convert';

class UserRequest {
  final String intent;
  final String documents;

  UserRequest({required this.intent, required this.documents});
}

UserRequest parseLLMResponse(String llmOutput) {
  try {
    // Clean and strip markdown wrappers if present
    String cleaned = llmOutput.trim();
    if (cleaned.startsWith("```")) {
      final jsonStart = cleaned.indexOf("{");
      final jsonEnd = cleaned.lastIndexOf("}");
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        cleaned = cleaned.substring(jsonStart, jsonEnd + 1);
      }
    }

    // Parse the JSON string into a Map
    final Map<String, dynamic> parsedData = jsonDecode(cleaned);

    // Safely extract fields with user_intent key fallback
    String intent = "user_intent";
    String documents = "";
    if (parsedData.containsKey("user_intent")) {
      documents = parsedData["user_intent"]?.toString() ?? "";
    } else if (parsedData.isNotEmpty) {
      intent = parsedData.keys.first;
      documents = parsedData[intent]?.toString() ?? "";
    }

    return UserRequest(intent: intent, documents: documents);
  } catch (e) {
    throw Exception("json_convert.parseLLMResponse Error: ${e.toString()} | Raw output: $llmOutput");
  }
}