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
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend(ChatbotController controller) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    controller.sendMessage(text);
    _textController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatbotController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          // ── Chat Messages ──
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: controller.messages.length + (controller.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Show typing indicator as the first item (index 0) when loading
                if (controller.isLoading && index == 0) {
                  return const _TypingIndicator();
                }

                final adjustedIndex = controller.isLoading ? index - 1 : index;
                final msg = controller.messages[adjustedIndex];
                final isUser = msg["role"] == "user";

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isUser) ...[
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFF1E88E5),
                          child: Text('B', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF1E88E5) : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isUser ? 16 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            msg["text"] ?? "",
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: isUser ? Colors.white : const Color(0xFF2D2D2D),
                            ),
                          ),
                        ),
                      ),
                      if (isUser) const SizedBox(width: 8),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Collapsible Checklist Suggestion ──
          if (controller.lastSuggestedRequirements.isNotEmpty)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row — always visible
                  InkWell(
                    onTap: () => controller.toggleChecklistCollapse(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.checklist_rounded, color: Color(0xFF1E88E5), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Add ${controller.lastSuggestedRequirements.length} items to checklist?",
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                          AnimatedRotation(
                            turns: controller.isChecklistCollapsed ? 0 : 0.5,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(Icons.expand_more, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expandable body
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: controller.isChecklistCollapsed
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          ...controller.lastSuggestedRequirements.map(
                            (req) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(Icons.circle, size: 6, color: Color(0xFF1E88E5)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(req, style: const TextStyle(fontSize: 13, height: 1.3)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => controller.confirmChecklistTask(),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text("Add to Checklist"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E88E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 10),
                              TextButton(
                                onPressed: () => controller.clearSuggestion(),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey.shade600,
                                ),
                                child: const Text("Dismiss"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Input Field ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 130),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    enabled: !controller.isLoading,
                    onSubmitted: (_) => _handleSend(controller),
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: controller.isLoading ? 'BINO is thinking...' : 'Ask BINO anything...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                      filled: true,
                      fillColor: const Color(0xFFF2F3F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                    color: controller.isLoading ? Colors.grey.shade300 : const Color(0xFF1E88E5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: controller.isLoading ? null : () => _handleSend(controller),
                    icon: const Icon(Icons.send_rounded, size: 20),
                    color: Colors.white,
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated "typing" indicator with 3 bouncing dots
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    // Stagger the animations
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFF1E88E5),
            child: Text('B', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animations[i],
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _animations[i].value),
                    child: child,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
