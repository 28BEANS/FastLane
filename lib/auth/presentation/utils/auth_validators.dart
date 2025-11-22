String? validatePassword(String password) {
  if (password.length < 10) return 'Password must be at least 10 characters long.';
  if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Password must contain an uppercase letter.';
  if (!RegExp(r'[a-z]').hasMatch(password)) return 'Password must contain a lowercase letter.';
  if (!RegExp(r'[0-9]').hasMatch(password)) return 'Password must contain a number.';
  if (!RegExp(r'[!@#\$%\^&\*]').hasMatch(password)) return 'Password must contain a special character (!@#\$%^&*).';
  return null;
}

String? validateRegistration(
  String firstName,
  String lastName,
  String email,
  String password,
  String confirmPassword,
) {
  if (firstName.trim().isEmpty) return 'First Name is required.';
  if (lastName.trim().isEmpty) return 'Last Name is required.';
  if (email.trim().isEmpty) return 'Email is required.';
  if (password != confirmPassword) return 'Passwords do not match.';
  return validatePassword(password);
}
