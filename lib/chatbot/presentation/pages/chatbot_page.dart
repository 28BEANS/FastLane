import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/chatbot_controller.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatbotController>();

    return Scaffold(
      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final msg = controller.messages[index];
                final isUser = msg["role"] == "user";

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFFC3C3C3) : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(msg["text"] ?? ""),
                    ),
                  ),
                );
              },
            ),
          ),

          if (controller.lastSuggestedRequirements.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add these to your checklist?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...controller.lastSuggestedRequirements.map(
                    (req) => Text("• $req", style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          controller.confirmChecklistTask();
                        },
                        child: const Text("Add"),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          controller.clearSuggestion();
                        },
                        child: const Text("Cancel"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.only(bottom: 95, left: 16, right: 16),
            child: TextFormField(
              controller: _textController,
              onFieldSubmitted: (value) {
                controller.sendMessage(value);
                _textController.clear();
              },
              decoration: InputDecoration(
                hintText: 'Press here to talk with BINO',
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
                filled: true,
                fillColor: const Color(0xFFF4F4F4),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    controller.sendMessage(_textController.text);
                    _textController.clear();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Color(0xFF919191), width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
