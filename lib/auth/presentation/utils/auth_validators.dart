String? validatePassword(String password) {
  if (password.length < 10) return 'Password must be at least 10 characters long.';
  if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Password must contain an uppercase letter.';
  if (!RegExp(r'[a-z]').hasMatch(password)) return 'Password must contain a lowercase letter.';
  if (!RegExp(r'[0-9]').hasMatch(password)) return 'Password must contain a number.';
  if (!RegExp(r'[!@#\$%\^&\*]').hasMatch(password)) return 'Password must contain a special character (!@#\$%^&*).';
  return null;
}

/// Step 1: Validate basic registration fields (first page)
String? validateRegistrationStep1(
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

/// Step 2: Validate address fields (second page)
String? validateRegistrationStep2({
  required String country,
  required String region,
  required String city,
  required String street,
}) {
  if (country.trim().isEmpty) return 'Country is required.';
  if (region.trim().isEmpty) return 'Region/Province is required.';
  if (city.trim().isEmpty) return 'City is required.';
  if (street.trim().isEmpty) return 'Street address is required.';
  return null;
}
