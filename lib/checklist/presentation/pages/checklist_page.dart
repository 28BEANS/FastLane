import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/checklist_controller.dart';

class ChecklistPage extends StatelessWidget {
  const ChecklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistController>(
      builder: (context, controller, child) {
        final tasks = controller.tasks;

        if (tasks.isEmpty) {
          return const Center(child: Text("No tasks yet."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(task.taskName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        value: task.progress,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.blue,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
                children: task.items.map((item) {
                  return CheckboxListTile(
                    title: Text(item.label),
                    value: item.done,
                    onChanged: (_) {
                      controller.toggleItemDone(task, item);
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
