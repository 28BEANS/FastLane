import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../auth/presentation/pages/register_page.dart';
import '../../auth/presentation/pages/forgot_password_page.dart';
import '../../home/presentation/pages/home_page.dart'; 
import '../../chatbot/presentation/pages/chatbot_page.dart'; 

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) {
      final authController = context.read<AuthController>();

      switch (settings.name) {
        case '/login':
          return const LoginPage();
        case '/register':
          return const RegisterPage();
        case '/forgot-password':
          return const ForgotPasswordPage();
        case '/home':
          if (!authController.isLoggedIn) return const LoginPage();
          return const HomePage();
        case '/chatbot':
          if (!authController.isLoggedIn) return const LoginPage();
          return const ChatbotPage();
        default:
          return const Scaffold(
            body: Center(child: Text('Route not found')),
          );
      }
    });
  }
}
