import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController()..mode = AuthMode.login,
      child: Consumer<AuthController>(
        builder: (_, c, __) => WillPopScope(
          onWillPop: () async => false, // Disable system back button
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Login'),
              automaticallyImplyLeading: false, // remove back arrow
            ),
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
                            : const Text('LOGIN'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text('Need an account? Register'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: const Text('Forgot Password?'),
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
