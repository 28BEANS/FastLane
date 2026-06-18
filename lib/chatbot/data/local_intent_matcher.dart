import 'package:flutter/foundation.dart';

/// A purely local, offline-capable intent matcher.
///
/// When the Gemini API is unavailable (no internet, quota exceeded, etc.),
/// this class is used as a fallback to determine what government document
/// the user is asking about by keyword matching.
class LocalIntentMatcher {
  /// Maps document name → list of trigger keywords.
  static const Map<String, List<String>> _keywordMap = {
    'birthCert': [
      'birth', 'birth certificate', 'psa', 'nso', 'borned', 'born',
      'birth cert', 'bc', 'certificate of live birth',
    ],
    'passport': [
      'passport', 'travel document', 'dfa', 'travel', 'abroad',
      'international id', 'visa', 'foreign', 'oefd',
    ],
    'driverLicense': [
      'driver', 'license', 'licence', 'lto', 'driving', 'adl',
      'driver\'s license', 'operator\'s permit', 'drive',
    ],
    'nationalID': [
      'national id', 'philsys', 'phil sys', 'national identity',
      'psn', 'philippine id', 'natid', 'national',
    ],
    'seniorCitizen': [
      'senior', 'senior citizen', 'osca', 'elderly', 'senior id',
      'old age', 'pensioner', '60 years', 'retirement',
    ],
    'schoolID': [
      'school id', 'student id', 'school', 'student', 'ched',
      'college id', 'university id', 'school identification',
    ],
    'certificateOfRegistration': [
      'certificate of registration', 'cor', 'vehicle', 'car registration',
      'lto registration', 'motor vehicle', 'motorcycle registration',
      'registration certificate',
    ],
  };

  /// Pre-baked offline requirements for each document type.
  /// These serve as a sensible fallback when Firestore is unreachable.
  static const Map<String, List<String>> _offlineRequirements = {
    'birthCert': [
      'Valid government-issued ID of the requester',
      'Accomplished PSA application form',
      'Payment of processing fee (₱365 for express, ₱155 for standard)',
      'Authorization letter (if requesting on behalf of another person)',
    ],
    'passport': [
      'Accomplished DFA ePassport application form',
      'PSA-issued Birth Certificate',
      'Valid government-issued ID',
      'Proof of Philippine citizenship (if applicable)',
      'Passport fee payment (₱950 regular, ₱1,200 expedite)',
      'Old passport (for renewal)',
    ],
    'driverLicense': [
      'Accomplished LTO application form',
      'Medical certificate from accredited clinic',
      'Passing TDC (Theoretical Driving Course) certificate',
      'Passing PDC (Practical Driving Course) certificate (for new applicants)',
      'PSA Birth Certificate or valid ID',
      'License fee payment',
    ],
    'nationalID': [
      'PSA Birth Certificate',
      'Proof of address (utility bill, barangay certificate)',
      'One valid government-issued ID',
      'PhilSys registration — visit a PSA registration center',
    ],
    'seniorCitizen': [
      'Proof of age (PSA Birth Certificate)',
      'Proof of residency (barangay certification or utility bill)',
      'One valid government-issued ID',
      'Proceed to your local OSCA (Office for Senior Citizens Affairs)',
    ],
    'schoolID': [
      'Enrollment form / Certificate of enrollment',
      'Recent 1x1 or 2x2 ID photo',
      'Valid student registration (school clearance)',
      'Contact your school registrar for processing',
    ],
    'certificateOfRegistration': [
      'Official receipt of motor vehicle purchase',
      'Deed of sale / Invoice',
      'Insurance Certificate of Cover (CIC)',
      'MVIR (Motor Vehicle Inspection Report)',
      'PNP-HPG clearance (for used vehicles)',
      'Payment of registration fee at LTO',
    ],
  };

  /// Tries to match the [userMessage] to a known [DocumentType] by keyword.
  ///
  /// Returns `null` if no match is found.
  static String? matchDocument(String userMessage) {
    final lower = userMessage.toLowerCase();

    String? bestMatch;
    int bestScore = 0;

    for (final entry in _keywordMap.entries) {
      int score = 0;
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) {
          // Longer keyword matches score higher (more specific)
          score += keyword.length;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestMatch = entry.key;
      }
    }

    if (bestScore == 0) {
      debugPrint('[LocalIntentMatcher] No match found for: "$userMessage"');
      return null;
    }

    debugPrint('[LocalIntentMatcher] Matched "$userMessage" → $bestMatch (score: $bestScore)');
    return bestMatch;
  }

  /// Returns pre-baked offline requirements for a document type name.
  /// Falls back to an empty list if the document isn't in the map.
  static List<String> getOfflineRequirements(String documentName) {
    return _offlineRequirements[documentName] ?? [];
  }

  /// Generates a friendly offline response for the matched document.
  static String buildOfflineResponse({
    required String documentName,
    required List<String> requirements,
  }) {
    if (requirements.isEmpty) {
      return "I'm currently offline and couldn't find specific requirements "
          "for \"$documentName\". Please check your connection and try again, "
          "or visit the relevant government office directly.";
    }

    final friendlyName = _friendlyName(documentName);
    final reqList = requirements.map((r) => '• $r').join('\n');

    return "📋 Here are the requirements for **$friendlyName** "
        "(offline mode — based on standard Philippine government guidelines):\n\n"
        "$reqList\n\n"
        "_Note: Requirements may vary. Always confirm with the issuing office._";
  }

  /// Friendly display name for a document key.
  static String _friendlyName(String key) {
    const names = {
      'birthCert': 'PSA Birth Certificate',
      'passport': 'Philippine Passport',
      'driverLicense': "Driver's License (LTO)",
      'nationalID': 'National ID (PhilSys)',
      'seniorCitizen': 'Senior Citizen ID (OSCA)',
      'schoolID': 'School / Student ID',
      'certificateOfRegistration': 'Certificate of Registration (LTO)',
    };
    return names[key] ?? key;
  }
}
