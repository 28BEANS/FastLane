import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../chatbot/presentation/controllers/chatbot_controller.dart';

class ChecklistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatbotController>(
      builder: (context, chat, child) {
        final items = chat.userChecklist;

        if (items.isEmpty) {
          return Center(
            child: Text("No checklist items yet."),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                leading: Icon(Icons.checklist),
                title: Text(items[index]),
              ),
            );
          },
        );
      },
    );
  }
}
