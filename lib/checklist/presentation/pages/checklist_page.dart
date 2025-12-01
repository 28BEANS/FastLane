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
            final progressPercentage = (task.progress * 100).toInt();

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.taskName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: LinearProgressIndicator(
                            value: task.progress,
                            backgroundColor: Colors.grey.shade300,
                            color: Colors.blue,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text("$progressPercentage%"),
                      ],
                    ),
                  ],
                ),
                children: task.items.map((item) {
                  return ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.done ? Colors.green : Colors.transparent,
                        border: Border.all(
                            color: item.done ? Colors.green : Colors.grey),
                      ),
                      child: item.done
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                    title: Text(item.label),
                    trailing: item.done
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Confirm"),
                                  content: Text(
                                      "Mark '${item.label}' as incomplete?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Confirm"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm ?? false) {
                                controller.toggleItemDone(task, item);
                              }
                            },
                            child: const Text("Undone"),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Confirm"),
                                  content: Text(
                                      "Mark '${item.label}' as done?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Confirm"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm ?? false) {
                                controller.toggleItemDone(task, item);
                              }
                            },
                            child: const Text("Done"),
                          ),
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
