import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

class GlobalHeader extends StatelessWidget {
  const GlobalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = auth.userProfile;

    final name = profile != null
        ? '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'.trim()
        : 'Guest User';

    final email = profile != null
        ? (profile['email'] as String? ?? '')
        : (auth.isLoggedIn
            ? (auth.email.text.isNotEmpty ? auth.email.text : 'No Email')
            : 'Not Logged In');

    final city = profile != null ? (profile['city'] as String? ?? '') : '';
    final country =
        profile != null ? (profile['country'] as String? ?? '') : '';
    final location = (city.isNotEmpty && country.isNotEmpty)
        ? '$city, $country'
        : (city.isNotEmpty
            ? city
            : (country.isNotEmpty ? country : 'Location not set'));

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name
              Text(
                name.isEmpty ? 'Anonymous' : name,
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 4),

              // Email
              Text(
                email,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 6),

              // Location row
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
