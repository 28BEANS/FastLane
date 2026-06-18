import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'local_intent_matcher.dart';

class LlmService {
  late final GenerativeModel _model;

  // Use gemini-1.5-flash — broader free-tier quota than 2.5-flash
  static const String _modelName = 'gemini-2.0-flash';

  // Retry configuration
  static const int _maxRetries = 2;
  static const Duration _retryBaseDelay = Duration(seconds: 2);

  LlmService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(model: _modelName, apiKey: apiKey);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Connectivity helper
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns true if the device has an active network connection.
  Future<bool> _isOnline() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Retry wrapper
  // ─────────────────────────────────────────────────────────────────────────

  /// Calls [fn], retrying up to [_maxRetries] times with exponential backoff
  /// on transient errors (SocketException, 429 rate limit).
  Future<T> _withRetry<T>(Future<T> Function() fn) async {
    int attempt = 0;
    while (true) {
      try {
        return await fn();
      } on SocketException catch (e) {
        attempt++;
        if (attempt > _maxRetries) rethrow;
        final delay = _retryBaseDelay * attempt;
        debugPrint('[LlmService] SocketException on attempt $attempt, retrying in ${delay.inSeconds}s: $e');
        await Future.delayed(delay);
      } catch (e) {
        // Check for 429 / quota errors from Gemini SDK
        final msg = e.toString().toLowerCase();
        if ((msg.contains('429') || msg.contains('quota') || msg.contains('resource_exhausted'))
            && attempt < _maxRetries) {
          attempt++;
          final delay = _retryBaseDelay * attempt;
          debugPrint('[LlmService] Rate limit on attempt $attempt, retrying in ${delay.inSeconds}s');
          await Future.delayed(delay);
        } else {
          rethrow;
        }
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Intent identification
  // ─────────────────────────────────────────────────────────────────────────

  /// Identifies the document the user is asking about.
  ///
  /// Strategy:
  ///   1. Check connectivity.
  ///   2. If online → try Gemini with retry backoff.
  ///   3. If offline or Gemini fails → fall back to [LocalIntentMatcher].
  Future<LlmResult> identifyUserIntent(
    List<String> availableDocuments,
    String userMessage,
  ) async {
    final online = await _isOnline();

    if (online) {
      try {
        final response = await _withRetry(() => _callGeminiIntent(availableDocuments, userMessage));
        return LlmResult(rawJson: response, isOffline: false);
      } catch (e) {
        debugPrint('[LlmService] Gemini intent failed, falling back to local matcher: $e');
      }
    } else {
      debugPrint('[LlmService] Device is offline — using LocalIntentMatcher.');
    }

    // Offline / fallback path
    final matched = LocalIntentMatcher.matchDocument(userMessage);
    final json = jsonEncode({'user_intent': matched ?? ''});
    return LlmResult(rawJson: json, isOffline: true, matchedDocument: matched);
  }

  Future<String> _callGeminiIntent(List<String> availableDocuments, String userMessage) async {
    debugPrint('[LlmService] identifyUserIntent → Gemini [$_modelName]');
    final data = await _model.generateContent(
      [
        Content.text(
          'You are Juan, a government service assistant.\n'
          'Task: Determine which single government document the user needs.\n\n'
          'Available documents: ${availableDocuments.join(', ')}\n\n'
          'Rules:\n'
          '1. Analyze the user\'s message.\n'
          '2. If it clearly matches one document, return that document name exactly.\n'
          '3. If it does NOT match any document, return null.\n'
          '4. OUTPUT ONLY JSON in EXACTLY this format:\n'
          '{"user_intent": "<DocumentName OR null>"}\n\n'
          'User request: $userMessage',
        )
      ],
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
    final response = data.text ?? '{}';
    debugPrint('[LlmService] Gemini intent response: $response');
    return response;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Document response generation
  // ─────────────────────────────────────────────────────────────────────────

  /// Generates a friendly reply about document requirements.
  ///
  /// If offline or Gemini fails, builds a local template response instead.
  Future<String> generateDocumentResponse({
    required bool hasDocs,
    required String intent,
    required String document,
    required List<String> requirements,
    required bool isOffline,
  }) async {
    // Always use local response when offline or no docs
    if (isOffline) {
      return LocalIntentMatcher.buildOfflineResponse(
        documentName: document,
        requirements: requirements,
      );
    }

    if (!hasDocs) {
      return "I'm sorry, I don't have information about \"$document\" in our database yet. "
          "Please try asking about a different document or contact the relevant government office.";
    }

    final online = await _isOnline();
    if (!online) {
      return LocalIntentMatcher.buildOfflineResponse(
        documentName: document,
        requirements: requirements,
      );
    }

    try {
      return await _withRetry(() => _callGeminiResponse(
        intent: intent,
        document: document,
        requirements: requirements,
        hasDocs: hasDocs,
      ));
    } catch (e) {
      debugPrint('[LlmService] Gemini response failed, using local template: $e');
      return LocalIntentMatcher.buildOfflineResponse(
        documentName: document,
        requirements: requirements,
      );
    }
  }

  Future<String> _callGeminiResponse({
    required bool hasDocs,
    required String intent,
    required String document,
    required List<String> requirements,
  }) async {
    debugPrint('[LlmService] generateDocumentResponse → Gemini [$_modelName]');
    final reqList = requirements.join(', ');
    final prompt = hasDocs
        ? 'Based on the user\'s intent: "$intent", and the document they need: "$document", '
          'the required documents are: $reqList.\n\nWrite a friendly answer listing these.'
        : 'The document "$document" is not in our database. Write a friendly response saying this.';

    final data = await _model.generateContent([Content.text(prompt)]);
    return data.text ?? "Sorry, I couldn't generate a response.";
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result wrapper
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps the result of intent identification, carrying whether it came
/// from Gemini (online) or the local matcher (offline).
class LlmResult {
  final String rawJson;
  final bool isOffline;
  final String? matchedDocument;

  const LlmResult({
    required this.rawJson,
    required this.isOffline,
    this.matchedDocument,
  });
}