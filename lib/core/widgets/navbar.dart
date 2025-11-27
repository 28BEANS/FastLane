// gayahin yung nassa figma tas lagyan ng logout button na maglo-logout sa user using AuthController

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogout;

  const AppNavBar({
    super.key,
    required this.title,
    this.showLogout = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (showLogout)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authController = context.read<AuthController>();
              await authController.logout();
              // Navigate to login page and clear stack
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
