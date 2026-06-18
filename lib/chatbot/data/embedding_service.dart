import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for generating text embeddings using the Gemini embedding model.
/// Converts text into numerical vectors that capture semantic meaning,
/// enabling similarity-based retrieval in the RAG pipeline.
class EmbeddingService {
  late final GenerativeModel _model;

  EmbeddingService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(model: 'gemini-embedding-001', apiKey: apiKey);
  }

  /// Generate an embedding vector for a single piece of text.
  Future<List<double>> embedText(String text) async {
    try {
      final result = await _model.embedContent(Content.text(text));
      return result.embedding.values;
    } catch (e) {
      print('[ERROR] EmbeddingService.embedText: $e');
      rethrow;
    }
  }

  /// Generate embeddings for multiple texts in sequence.
  /// Returns a list of vectors in the same order as the input texts.
  /// Each text is embedded individually to avoid API batch limits.
  Future<List<List<double>>> embedBatch(List<String> texts) async {
    print('[INFO] EmbeddingService.embedBatch: Embedding ${texts.length} texts...');
    final List<List<double>> embeddings = [];

    for (int i = 0; i < texts.length; i++) {
      final embedding = await embedText(texts[i]);
      embeddings.add(embedding);

      // Progress logging every 10 chunks
      if ((i + 1) % 10 == 0 || i == texts.length - 1) {
        print('[INFO] EmbeddingService.embedBatch: ${i + 1}/${texts.length} done');
      }
    }

    return embeddings;
  }
}
