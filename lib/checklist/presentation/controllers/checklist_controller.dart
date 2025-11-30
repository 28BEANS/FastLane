import 'package:flutter/foundation.dart';

class ChecklistItem {
  String label;
  bool done;

  ChecklistItem({required this.label, this.done = false});
}

class ChecklistTask {
  String taskName;
  List<ChecklistItem> items;

  ChecklistTask({required this.taskName, required this.items});

  double get progress {
    if (items.isEmpty) return 0;
    final completed = items.where((i) => i.done).length;
    return completed / items.length;
  }
}

class ChecklistController with ChangeNotifier {
  List<ChecklistTask> tasks = [];

  void addTask(String taskName, List<String> requirements) {
    if (requirements.isEmpty) return;
    final newTask = ChecklistTask(
      taskName: taskName,
      items: requirements.map((r) => ChecklistItem(label: r)).toList(),
    );
    tasks.add(newTask);
    notifyListeners();
  }

  void toggleItemDone(ChecklistTask task, ChecklistItem item) {
    item.done = !item.done;
    notifyListeners();
  }
}
