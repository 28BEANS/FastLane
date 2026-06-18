import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/knowledge_chunk.dart';

/// Service to fetch knowledge chunks from the Firestore `knowledge_base` collection.
class KnowledgeBaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all knowledge chunks from Firestore.
  /// Returns every document in the `knowledge_base` collection as a
  /// [KnowledgeChunk]. These chunks are later embedded and indexed
  /// by the [VectorStore] for similarity search.
  Future<List<KnowledgeChunk>> fetchAllChunks() async {
    print('[INFO] KnowledgeBaseService.fetchAllChunks: Fetching knowledge base...');

    try {
      final snapshot = await _firestore.collection('knowledge_base').get();

      final chunks = snapshot.docs
          .map((doc) => KnowledgeChunk.fromFirestore(doc.data()))
          .toList();

      print('[INFO] KnowledgeBaseService.fetchAllChunks: Loaded ${chunks.length} chunks');
      return chunks;
    } catch (e) {
      print('[ERROR] KnowledgeBaseService.fetchAllChunks: $e');
      return [];
    }
  }

  /// Fetch knowledge chunks filtered by document type.
  /// Useful if you want to narrow retrieval to only the identified document.
  Future<List<KnowledgeChunk>> fetchChunksByDocumentType(String documentType) async {
    print('[INFO] KnowledgeBaseService.fetchChunksByDocumentType: Fetching for $documentType');

    try {
      final snapshot = await _firestore
          .collection('knowledge_base')
          .where('documentType', isEqualTo: documentType)
          .get();

      final chunks = snapshot.docs
          .map((doc) => KnowledgeChunk.fromFirestore(doc.data()))
          .toList();

      print('[INFO] KnowledgeBaseService.fetchChunksByDocumentType: Loaded ${chunks.length} chunks for $documentType');
      return chunks;
    } catch (e) {
      print('[ERROR] KnowledgeBaseService.fetchChunksByDocumentType: $e');
      return [];
    }
  }
}
