import 'package:flutter/foundation.dart';
import 'dart:math';
import 'models/knowledge_chunk.dart';
import 'embedding_service.dart';
import 'knowledge_base_service.dart';

/// In-memory vector store for semantic similarity search.
/// Holds [KnowledgeChunk] objects with their computed embeddings.
/// On initialization, fetches all chunks from Firestore and embeds
/// them using the [EmbeddingService]. Queries are embedded at search
/// time and compared via cosine similarity.
class VectorStore {
  final EmbeddingService _embeddingService;
  final KnowledgeBaseService _knowledgeBaseService;

  List<KnowledgeChunk> _chunks = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  int get chunkCount => _chunks.length;

  VectorStore({
    required EmbeddingService embeddingService,
    required KnowledgeBaseService knowledgeBaseService,
  })  : _embeddingService = embeddingService,
        _knowledgeBaseService = knowledgeBaseService;

  /// Initialize the vector store by fetching all knowledge chunks
  /// from Firestore and computing their embeddings.
  /// This is called lazily on the first chatbot message. Subsequent
  /// calls are no-ops thanks to the [_isInitialized] guard.
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('[INFO] VectorStore.initialize: Starting initialization...');

    // 1. Fetch all knowledge chunks from Firestore
    _chunks = await _knowledgeBaseService.fetchAllChunks();

    if (_chunks.isEmpty) {
      debugPrint('[WARN] VectorStore.initialize: No knowledge chunks found in Firestore!');
      return;
    }

    // 2. Compute embeddings for all chunks
    final texts = _chunks.map((c) => c.embeddingText).toList();
    final embeddings = await _embeddingService.embedBatch(texts);

    // 3. Attach embeddings to chunks
    for (int i = 0; i < _chunks.length; i++) {
      _chunks[i].embedding = embeddings[i];
    }

    _isInitialized = true;
    debugPrint('[INFO] VectorStore.initialize: Ready with ${_chunks.length} embedded chunks.');
  }

  /// Search for the top-K most similar knowledge chunks to the given query.
  /// Optionally filter results to a specific [documentType] for more focused
  /// retrieval when the user's intent has already been identified.
  Future<List<KnowledgeChunk>> search(
    String query, {
    int topK = 3,
    String? documentType,
  }) async {
    if (!_isInitialized || _chunks.isEmpty) {
      debugPrint('[WARN] VectorStore.search: Not initialized or empty.');
      return [];
    }

    // Embed the user's query
    final queryEmbedding = await _embeddingService.embedText(query);

    // Filter chunks by document type if specified
    final candidates = documentType != null
        ? _chunks.where((c) => c.documentType == documentType).toList()
        : _chunks;

    if (candidates.isEmpty) return [];

    // Compute similarity scores
    final scored = candidates
        .where((c) => c.embedding != null)
        .map((c) => _ScoredChunk(
              chunk: c,
              score: _cosineSimilarity(queryEmbedding, c.embedding!),
            ))
        .toList();

    // Sort by score descending and take top-K
    scored.sort((a, b) => b.score.compareTo(a.score));

    final results = scored.take(topK).toList();

    // Debug logging
    for (final r in results) {
      debugPrint('[INFO] VectorStore.search: ${r.chunk.title} (score: ${r.score.toStringAsFixed(4)})');
    }

    return results.map((r) => r.chunk).toList();
  }

  /// Cosine similarity between two vectors.
  /// Returns a value between -1 and 1, where 1 means identical direction.
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    final denominator = sqrt(normA) * sqrt(normB);
    if (denominator == 0) return 0.0;

    return dotProduct / denominator;
  }
}

/// Internal helper to pair a chunk with its similarity score.
class _ScoredChunk {
  final KnowledgeChunk chunk;
  final double score;

  _ScoredChunk({required this.chunk, required this.score});
}
