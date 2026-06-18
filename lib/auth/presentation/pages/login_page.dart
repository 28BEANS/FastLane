import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    // Reset the controller mode/fields when entering the page
    // Using addPostFrameCallback ensures we don't modify state during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().mode = AuthMode.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ACCESS GLOBAL CONTROLLER (Do not create a new one here)
    return Consumer<AuthController>(
      builder: (_, c, child) => PopScope(
        canPop: false, // Disables system back button
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Login'),
            automaticallyImplyLeading: false,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
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
                          // Ensure your controller has a toggle method or use setter
                          c.togglePasswordVisibility(); 
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
                                      final error = await c.login(); 
                                      if (error != null) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(error)),
                                          );
                                        }
                                      } else {
                                        if (context.mounted) {
                                          Navigator.pushReplacementNamed(context, '/dashboard');
                                        }
                                      }
                                    },
                              child: c.loading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('LOGIN'),
                            ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Need an account? Register'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
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