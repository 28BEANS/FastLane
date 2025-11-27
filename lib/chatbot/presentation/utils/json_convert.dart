import 'dart:convert';

class UserRequest {
  final String intent;
  final String documents;

  UserRequest({required this.intent, required this.documents});
}

UserRequest parseLLMResponse(String llmOutput) {
  // Parse the JSON string into a Map
  final Map<String, dynamic> parsedData = jsonDecode(llmOutput);

  // Since the JSON has only one key-value pair, extract it
  final String intent = parsedData.keys.first;
  final String documents = parsedData[intent];

  return UserRequest(intent: intent, documents: documents);
}
