import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController()..mode = AuthMode.register,
      child: Consumer<AuthController>(
        builder: (_, c, __) => Scaffold(
          appBar: AppBar(title: const Text('Register')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AuthTextField(
                      controller: c.firstName,
                      label: 'First Name',
                      icon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 15),
                    AuthTextField(
                      controller: c.lastName,
                      label: 'Last Name',
                      icon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 15),
                    AuthTextField(
                      controller: c.middleName,
                      label: 'Middle Name (Optional)',
                      icon: Icons.badge_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 15),
                    AuthTextField(
                      controller: c.email,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 15),
                    AuthTextField(
                      controller: c.password,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscure: !c.passwordVisible,
                      suffix: IconButton(
                        icon: Icon(c.passwordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          c.passwordVisible = !c.passwordVisible;
                          c.notifyListeners();
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    AuthTextField(
                      controller: c.confirmPassword,
                      label: 'Confirm Password',
                      icon: Icons.lock_reset_outlined,
                      obscure: !c.confirmPasswordVisible,
                      suffix: IconButton(
                        icon: Icon(c.confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          c.confirmPasswordVisible = !c.confirmPasswordVisible;
                          c.notifyListeners();
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: c.loading
                            ? null
                            : () async {
                                final error = await c.submit();
                                if (error != null) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text(error)));
                                } else {
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              },
                        child: c.loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('REGISTER'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Already have an account? Log In'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
