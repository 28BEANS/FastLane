import 'package:flutter/material.dart';
import '../../data/auth_service.dart';
import '../utils/auth_validators.dart';

enum AuthMode { login, register, forgotPassword }

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Controllers
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final middleName = TextEditingController();

  // State
  AuthMode mode = AuthMode.login;
  bool loading = false;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  void toggleForm() {
    mode = mode == AuthMode.login ? AuthMode.register : AuthMode.login;
    clearControllers();
    notifyListeners();
  }

  void toggleForgotPassword() {
    mode = mode == AuthMode.forgotPassword ? AuthMode.login : AuthMode.forgotPassword;
    clearControllers();
    notifyListeners();
  }

  void clearControllers() {
    email.clear();
    password.clear();
    confirmPassword.clear();
    firstName.clear();
    lastName.clear();
    middleName.clear();
  }

  Future<String?> submit() async {
    if (loading) return null;
    loading = true;
    notifyListeners();

    try {
      if (mode == AuthMode.login) {
        await _authService.signIn(email.text.trim(), password.text.trim());
      } else if (mode == AuthMode.register) {
        final error = validateRegistration(
          firstName.text,
          lastName.text,
          email.text,
          password.text,
          confirmPassword.text,
        );
        if (error != null) return error;

        await _authService.createAccount(
          email: email.text.trim(),
          password: password.text.trim(),
          firstName: firstName.text.trim(),
          lastName: lastName.text.trim(),
          middleName: middleName.text.trim(),
        );
      } else if (mode == AuthMode.forgotPassword) {
        if (email.text.trim().isEmpty) return 'Please enter your email';
        await _authService.resetPassword(email: email.text.trim());
      }
    } catch (e) {
      return e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }

    return null;
  }
}
