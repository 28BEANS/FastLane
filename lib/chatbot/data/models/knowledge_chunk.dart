/// A single chunk of knowledge about a government document.
/// Each chunk represents a focused piece of information (e.g. fees, steps,
/// eligibility) for a specific document type. The [embedding] field is
/// computed at runtime by the embedding service — it is NOT stored in Firestore.
class KnowledgeChunk {
  final String documentType;
  final String title;
  final String content;
  final String category;

  /// Vector embedding computed at runtime for similarity search.
  /// Null until the EmbeddingService populates it.
  List<double>? embedding;

  KnowledgeChunk({
    required this.documentType,
    required this.title,
    required this.content,
    required this.category,
    this.embedding,
  });

  /// Create a KnowledgeChunk from a Firestore document snapshot.
  factory KnowledgeChunk.fromFirestore(Map<String, dynamic> data) {
    return KnowledgeChunk(
      documentType: data['documentType'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? '',
    );
  }

  /// The full text used for embedding — combines title + content for richer semantic representation.
  String get embeddingText => '$title: $content';

  @override
  String toString() => 'KnowledgeChunk($documentType/$category: $title)';
}
