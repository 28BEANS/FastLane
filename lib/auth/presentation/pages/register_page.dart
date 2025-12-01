import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().mode = AuthMode.register;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (_, c, __) => Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                AuthTextField(
                  controller: c.firstName,
                  label: 'First Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 15),
                AuthTextField(
                  controller: c.lastName,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 15),
                AuthTextField(
                  controller: c.middleName,
                  label: 'Middle Name (Optional)',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 15),
                AuthTextField(
                  controller: c.email,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                AuthTextField(
                  controller: c.password,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscure: !c.passwordVisible,
                  suffix: IconButton(
                    icon: Icon(
                      c.passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: c.togglePasswordVisibility,
                  ),
                ),
                const SizedBox(height: 15),
                AuthTextField(
                  controller: c.confirmPassword,
                  label: 'Confirm Password',
                  icon: Icons.lock_reset_outlined,
                  obscure: !c.confirmPasswordVisible,
                  suffix: IconButton(
                    icon: Icon(
                      c.confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: c.toggleConfirmPasswordVisibility,
                  ),
                ),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final err = c.validateFirstPage();
                      if (err != null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(err)));
                        return;
                      }
                      Navigator.pushNamed(context, '/register-address');
                    },
                    child: const Text('NEXT'),
                  ),
                ),

                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Already have an account? Log In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
