// inside nav_controller.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/controllers/auth_controller.dart'; // REQUIRED IMPORT

class NavController extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void handleLogout(BuildContext context) {
    // Fetch the global AuthController instance
    final authController = context.read<AuthController>(); 

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
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Fix: Perform the actual sign-out using AuthController
              await authController.logout(); 

              if (context.mounted) {
                // Navigate to login and remove all previous routes
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  "/login", 
                  (route) => false,
                );
              }
            },
            child: const Text("Sign out"),
          ),
        ],
      ),
    );
  }
}