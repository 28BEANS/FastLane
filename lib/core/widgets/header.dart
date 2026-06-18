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
        ? "${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}".trim()
        : 'Guest User';
    final email = profile != null
        ? (profile['email'] ?? '')
        : (auth.isLoggedIn ? (auth.email.text.isNotEmpty ? auth.email.text : 'No Email') : 'Not Logged In');

    final city = profile != null ? (profile['city'] ?? '') : '';
    final country = profile != null ? (profile['country'] ?? '') : '';
    final location = (city.isNotEmpty && country.isNotEmpty)
        ? "$city, $country"
        : (city.isNotEmpty ? city : (country.isNotEmpty ? country : "Location not set"));

    return Container(
      width: double.infinity,
      height: 175,
      color: Colors.blue,
      padding: const EdgeInsets.only(left: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Transform.translate(
            offset: const Offset(0, 40),
            child: Text(
              name.isEmpty ? 'Anonymous' : name,
              style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 5),

          // Email
          Transform.translate(
            offset: const Offset(0, 35),
            child: Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),

          const SizedBox(height: 5),

          // Location
          Transform.translate(
            offset: const Offset(0, 30),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
