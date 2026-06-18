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
          // ── Offline banner ──────────────────────────────────────────────
          if (controller.isOfflineMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFFFF3CD),
              child: Row(
                children: const [
                  Icon(Icons.wifi_off_rounded, size: 16, color: Color(0xFF856404)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline mode — using built-in knowledge base',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF856404),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Message list ─────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final msg = controller.messages[index];
                final isUser = msg['role'] == 'user';
                final isOfflineMsg = msg['offline'] == 'true';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.78,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF3B82F6)
                            : (isOfflineMsg
                                ? const Color(0xFFFFF3CD)
                                : Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: isOfflineMsg
                            ? Border.all(
                                color: const Color(0xFFFFE083), width: 1)
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isOfflineMsg)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.wifi_off_rounded,
                                      size: 12, color: Color(0xFF856404)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Offline',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF856404),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Text(
                            msg['text'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: isUser
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Checklist suggestion panel ───────────────────────────────────
          if (controller.lastSuggestedRequirements.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(18),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.playlist_add_check_rounded,
                          size: 18, color: Color(0xFF3B82F6)),
                      SizedBox(width: 6),
                      Text(
                        'Add to your checklist?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...controller.lastSuggestedRequirements.map(
                    (req) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '• $req',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                        ),
                        onPressed: controller.confirmChecklistTask,
                        child: const Text('Add to Checklist'),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: controller.clearSuggestion,
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // ── Text input ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 95, left: 16, right: 16, top: 8),
            child: TextFormField(
              controller: _textController,
              onFieldSubmitted: (value) {
                if (value.trim().isEmpty) return;
                controller.sendMessage(value);
                _textController.clear();
              },
              decoration: InputDecoration(
                hintText: 'Ask BINO about a government document…',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 20),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded,
                      color: Color(0xFF3B82F6)),
                  onPressed: () {
                    if (_textController.text.trim().isEmpty) return;
                    controller.sendMessage(_textController.text);
                    _textController.clear();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB), width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB), width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                      color: Color(0xFF3B82F6), width: 2.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
