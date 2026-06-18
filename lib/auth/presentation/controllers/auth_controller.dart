import 'package:flutter/material.dart';
import '../../data/auth_service.dart';
import '../utils/auth_validators.dart';
import '../../data/geocoding_service.dart';

enum AuthMode { login, register, forgotPassword }

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? get userProfile => _userProfile;

  AuthController() {
    if (isLoggedIn) {
      fetchUserProfile();
    }
  }

  Future<void> fetchUserProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        final doc = await _authService.firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _userProfile = doc.data();
          notifyListeners();
        }
      } catch (e) {
        debugPrint("[ERROR] Failed to fetch user profile: $e");
      }
    }
  }

  // Controllers
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final middleName = TextEditingController();
  final country = TextEditingController();
  final region = TextEditingController();
  final city = TextEditingController();
  final street = TextEditingController();
  final postalCode = TextEditingController();

  // State
  AuthMode mode = AuthMode.login;
  bool loading = false;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  String? _selectedCountryCode;
  double? latitude;
  double? longitude;

  // ------------------------------------------------------------------
  // Visibility Toggle
  // ------------------------------------------------------------------
  void togglePasswordVisibility() {
    passwordVisible = !passwordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    confirmPasswordVisible = !confirmPasswordVisible;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Form Management
  // ------------------------------------------------------------------
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
    country.clear();
    region.clear();
    city.clear();
    street.clear();
    postalCode.clear();
    passwordVisible = false;
    confirmPasswordVisible = false;
  }

  // ------------------------------------------------------------------
  // Business Logic
  // ------------------------------------------------------------------
  bool get isLoggedIn => _authService.currentUser != null;

  // ---------------- Login ----------------
  Future<String?> login() async {
    if (loading) return null;
    loading = true;
    notifyListeners();

    try {
      if (email.text.trim().isEmpty) return 'Please enter your email';
      if (password.text.trim().isEmpty) return 'Please enter your password';
      await _authService.signIn(email.text.trim(), password.text.trim());
      await fetchUserProfile();
    } catch (e) {
      return e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }

    return null;
  }

  // ---------------- Forgot Password ----------------
  Future<String?> forgotPassword() async {
    if (loading) return null;
    loading = true;
    notifyListeners();

    try {
      if (email.text.trim().isEmpty) return 'Please enter your email';
      await _authService.resetPassword(email: email.text.trim());
    } catch (e) {
      return e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }

    return null;
  }

  // ---------------- Registration ----------------
  /// Step 1 validation only
  String? validateFirstPage() {
    return validateRegistrationStep1(
      firstName.text,
      lastName.text,
      email.text,
      password.text,
      confirmPassword.text,
    );
  }

  /// Step 2 submission + account creation
  Future<String?> submitRegistration() async {
    if (loading) return null;
    loading = true;
    notifyListeners();

    try {
      // Validate Step 1
      final step1Error = validateRegistrationStep1(
        firstName.text,
        lastName.text,
        email.text,
        password.text,
        confirmPassword.text,
      );
      if (step1Error != null) return step1Error;

      // Validate Step 2
      final addrError = validateRegistrationStep2(
        country: country.text,
        region: region.text,
        city: city.text,
        street: street.text,
      );
      if (addrError != null) return addrError;

      // Geocode address
      final ok = await resolveCoordinates();
      if (!ok) return "Unable to locate address. Please check your details.";

      // Create account in Firebase
      await _authService.createAccount(
        email: email.text.trim(),
        password: password.text.trim(),
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        middleName: middleName.text.trim(),
        countryCode: _selectedCountryCode ?? '',
        country: country.text.trim(),
        region: region.text.trim(),
        city: city.text.trim(),
        street: street.text.trim(),
        postalCode: postalCode.text.trim(),
        latitude: latitude,
        longitude: longitude,
      );
      await fetchUserProfile();
    } catch (e) {
      return e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }

    return null;
  }

  // ---------------- Logout ----------------
  Future<void> logout() async {
    try {
      await _authService.signOut();
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout failed: $e');
    }
  }

  // ---------------- Geocoding ----------------
  Future<bool> resolveCoordinates() async {
    final addresses = [
      "${street.text}, ${city.text}, ${region.text}, ${country.text}",
      "${city.text}, ${region.text}, ${country.text}",
      "${city.text}, Philippines",
    ];

    for (final address in addresses) {
      debugPrint('[GEOCODING] Trying: $address');
      final coords = await GeocodingService.getCoordinates(address);
      if (coords != null) {
        latitude = coords['lat'];
        longitude = coords['lng']; // ← was 'longitude', must match your service
        return true;
      }
    }
    return false;
  }

}
