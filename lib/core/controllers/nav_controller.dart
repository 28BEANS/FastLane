import 'package:flutter/material.dart';

class NavController extends ChangeNotifier {
  int currentIndex = 0;

  final List<String> routes = [
    "/home",
    "/checklist",
    "/chatbot",
    "/maps",
    "/logout",
  ];

  void handleTap(BuildContext context, int index) {
    if (index == 4) {
      _showLogoutDialog(context);
      return;
    }

    currentIndex = index;
    notifyListeners();

    Navigator.pushReplacementNamed(context, routes[index]);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sign out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, "/login");
            },
            child: const Text("Sign out"),
          ),
        ],
      ),
    );
  }
}
