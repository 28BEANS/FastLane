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
          Container(
            width: double.infinity,
            height: 175,
            color: Colors.blue,
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, 50),
                  child: const Text(
                    'Juan de la Cruz',
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 5),
                Transform.translate(
                  offset: const Offset(0, 40),
                  child: const Text(
                    'juandelacruz@email.com',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 5),
                Transform.translate(
                  offset: const Offset(30, 40),
                  child: const Text(
                    'Unemployed',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final msg = controller.messages[index];
                final isUser = msg["role"] == "user";

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 10.0),
                  child: Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFFC3C3C3)
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(msg["text"] ?? ""),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 150),
            child: TextFormField(
              controller: _textController,
              onFieldSubmitted: (value) {
                controller.sendMessage(value);
                _textController.clear();
              },
              decoration: InputDecoration(
                hintText: 'Press here to talk with BINO',
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 50),
                filled: true,
                fillColor: const Color(0xFFF4F4F4),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    controller.sendMessage(_textController.text);
                    _textController.clear();
                  },
                ),

                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  borderSide: BorderSide(
                    color: Color(0xFF919191),
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
