/*
  REFACTORED AUTH PAGE (auth_page.dart)
    - UI Presentation for Login and Register Page.
    - All Firebase/Firestore logic has been moved to auth_service.dart.

    Lead Author: Vince Evangelista 
    Contributor/s: Prince Pamintuan
    Created on: November 20, 2025
*/
import 'package:flutter/material.dart';
import 'home_page.dart';
import '../auth/auth_service.dart'; // Ensure this import path is correct

// Enum to manage the three distinct states of the authentication screen
enum AuthMode { login, register, forgotPassword }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Instantiate the service (Logic is now encapsulated here)
  final AuthService _authService = AuthService();

  // Controllers for all fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();

  // State Management
  AuthMode _authMode = AuthMode.login; // Default mode is Login
  bool _loading = false;
  // State for the View Password toggle:
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    // Proper disposal of controllers
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    super.dispose();
  }

  void _clearControllers() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _middleNameController.clear();
  }

  void _toggleForm() {
    setState(() {
      // Toggle between Login and Register
      if (_authMode == AuthMode.login) {
        _authMode = AuthMode.register;
      } else {
        _authMode = AuthMode.login;
      }
      _clearControllers();
    });
  }

  void _toggleForgotPassword() {
    setState(() {
      // Toggle between Forgot Password and Login
      if (_authMode == AuthMode.forgotPassword) {
        _authMode = AuthMode.login;
      } else {
        _authMode = AuthMode.forgotPassword;
      }
      _clearControllers();
    });
  }


  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _loading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_authMode == AuthMode.login) {
        // --- LOGIN: Call service function ---
        await _authService.signIn(email, password);
        
        if (mounted) {
          // Navigate to HomePage on success
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }

      } else if (_authMode == AuthMode.register) {
        // --- REGISTER: Call service function ---
        if (password != _confirmPasswordController.text.trim()) {
          throw Exception('Passwords do not match.');
        }

        await _authService.createAccount(
          email: email,
          password: password,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          middleName: _middleNameController.text.trim(),
        );
        
        if (mounted) {
          // Navigate to HomePage on success
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }

      } else if (_authMode == AuthMode.forgotPassword) {
        // --- FORGOT PASSWORD: Call service function ---
        
        // Validation check for Forgot Password mode
        if (email.isEmpty) {
          throw Exception('Please enter your email address.');
        }
        
        await _authService.resetPassword(email: email);
        if (mounted) {
          _showSnackBar('Password reset link sent to $email. Check your inbox.');
          
          // Return to login screen after sending the email
          setState(() {
            _authMode = AuthMode.login;
            _emailController.clear();
          });
        }
      }

    } on Exception catch (e) {
      // Catch exceptions from the service layer
      String errorMessage = e.toString().contains(']')
          ? e.toString().split(']').last.trim() // Clean up Firebase Auth error messages
          : e.toString().replaceFirst('Exception: ', '').trim(); // Clean up custom exceptions

      _showSnackBar(errorMessage);
    } finally {
      if (mounted) {
        // Stop loading regardless of success or failure in all modes.
        setState(() => _loading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  final double _inputWidth = 350.0;

  @override
  Widget build(BuildContext context) {
    String pageTitle = switch (_authMode) {
      AuthMode.login => 'Login',
      AuthMode.register => 'Register',
      AuthMode.forgotPassword => 'Reset Password'
    };

    String formTitle = switch (_authMode) {
      AuthMode.login => 'Welcome Back',
      AuthMode.register => 'Create Your Account',
      AuthMode.forgotPassword => 'Password Recovery'
    };

    String buttonText = switch (_authMode) {
      AuthMode.login => 'LOGIN',
      AuthMode.register => 'REGISTER',
      AuthMode.forgotPassword => 'SEND RESET LINK'
    };


    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Form Title
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Text(
                          formTitle,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),

                      // --- REGISTRATION FIELDS (Only visible on Register mode) ---
                      if (_authMode == AuthMode.register) ...[
                        _buildTextField(
                          controller: _firstNameController,
                          labelText: 'First Name',
                          icon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 15),

                        _buildTextField(
                          controller: _lastNameController,
                          labelText: 'Last Name',
                          icon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 15),

                        _buildTextField(
                          controller: _middleNameController,
                          labelText: 'Middle Name (Optional)',
                          icon: Icons.badge_outlined,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 15),
                      ],

                      // --- SHARED FIELD: Email ---
                      _buildTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: (_authMode == AuthMode.forgotPassword)
                            ? TextInputAction.done
                            : TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      // --- PASSWORD FIELDS (Hidden in Forgot Password mode) ---
                      if (_authMode != AuthMode.forgotPassword)
                        _buildTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: !_passwordVisible, // Use visibility state
                          textInputAction: (_authMode == AuthMode.login) 
                              ? TextInputAction.done 
                              : TextInputAction.next,
                          // Add the password visibility toggle
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible 
                                  ? Icons.visibility 
                                  : Icons.visibility_off,
                              color: Theme.of(context).hintColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                      
                      if (_authMode == AuthMode.register)
                        const SizedBox(height: 15),

                      if (_authMode == AuthMode.register)
                        // Confirm Password (Only for Registration)
                        _buildTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          icon: Icons.lock_reset_outlined,
                          obscureText: !_confirmPasswordVisible, // Use visibility state
                          textInputAction: TextInputAction.done,
                          // Add the password visibility toggle
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmPasswordVisible 
                                  ? Icons.visibility 
                                  : Icons.visibility_off,
                              color: Theme.of(context).hintColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _confirmPasswordVisible = !_confirmPasswordVisible;
                              });
                            },
                          ),
                        ),

                      const SizedBox(height: 30),

                      // --- SUBMIT BUTTON ---
                      SizedBox(
                        width: _inputWidth,
                        height: 50,
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                                onPressed: _submit,
                                child: Text(
                                  buttonText,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                      ),

                      const SizedBox(height: 20),
                      
                      // --- TOGGLE BUTTONS ---

                      // 1. Login/Register Toggle
                      TextButton(
                        onPressed: _toggleForm,
                        child: Text(
                          _authMode == AuthMode.login 
                              ? 'Need an account? Sign Up Now' 
                              : 'Already have an account? Log In',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // 2. Forgot Password Toggle (Now ONLY shown on Login screen)
                      // Condition changed from (_authMode != AuthMode.forgotPassword) to (_authMode == AuthMode.login)
                      if (_authMode == AuthMode.login) 
                        TextButton(
                          onPressed: _toggleForgotPassword,
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            )
                          ),
                        ),
                      
                      // 3. Back to Login (Only shown on Forgot Password screen)
                      if (_authMode == AuthMode.forgotPassword)
                        TextButton(
                          onPressed: _toggleForgotPassword,
                          child: Text(
                            "Back to Login",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            )
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to create a standardized TextField widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.done,
    // New optional parameter for suffixIcon
    Widget? suffixIcon,
  }) {
    return Container(
      width: _inputWidth,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Theme.of(context).hintColor),
          // Use the optional suffixIcon parameter
          suffixIcon: suffixIcon, 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
        ),
      ),
    );
  }
}