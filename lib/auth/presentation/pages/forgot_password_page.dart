import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController()..mode = AuthMode.forgotPassword,
      child: Consumer<AuthController>(
        builder: (_, c, __) => Scaffold(
          appBar: AppBar(title: const Text('Forgot Password')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AuthTextField(
                    controller: c.email,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
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
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(content: Text('Password reset link sent.')));
                                Navigator.pushReplacementNamed(context, '/login');
                              }
                            },
                      child: c.loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('SEND RESET LINK'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
