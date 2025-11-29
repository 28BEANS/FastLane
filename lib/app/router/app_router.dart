import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../auth/presentation/pages/register_page.dart';
import '../../auth/presentation/pages/forgot_password_page.dart';
import '../../core/utils/main_shell_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        final auth = context.read<AuthController>();

        // Guard: If not logged in and trying to access protected routes
        if (!auth.isLoggedIn && settings.name == '/dashboard') {
          return const LoginPage();
        }

        switch (settings.name) {
          case '/login':
            return const LoginPage();
          case '/register':
            return const RegisterPage();
          case '/forgot-password':
            return const ForgotPasswordPage();
          
          // One entry point for the entire authenticated app
          case '/dashboard':
            return const MainShellPage();

          default:
            return const Scaffold(
              body: Center(child: Text("Route not found")),
            );
        }
      },
    );
  }
}