import 'package:flutter/material.dart';

class NavController extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Handle Logout logic specifically
  void handleLogout(BuildContext context) {
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
              Navigator.pop(context); // Close dialog
              // Navigate to login and remove all previous routes
              Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
            },
            child: const Text("Sign out"),
          ),
        ],
      ),
    );
  }
}