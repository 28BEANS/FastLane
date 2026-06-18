import 'package:cloud_firestore/cloud_firestore.dart';

// In-memory cache for document requirements to prevent redundant Firestore reads
final Map<String, List<String>> _requirementsCache = {};

Future<List<String>> fetchDocumentRequirements(String documentName) async {
  if (_requirementsCache.containsKey(documentName)) {
    print("[INFO] chatbot_service: returning cached requirements for $documentName");
    return _requirementsCache[documentName]!;
  }

  print("[INFO] chatbot_service.fetchDocumentRequirements called with $documentName");
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    // Query the collection (assume collection is 'documents') for the matching document name
    final querySnapshot = await firestore
        .collection('requirements')
        .where('document', isEqualTo: documentName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return []; // No matching document found
    }

    // Assuming the document structure has a field 'requirements' which is an array of strings
    final docData = querySnapshot.docs.first.data();
    final List<dynamic> requirementsDynamic = docData['requirements'] ?? [];

    // Convert dynamic list to List<String>
    final List<String> requirements = requirementsDynamic.map((e) => e.toString()).toList();

    _requirementsCache[documentName] = requirements;
    return requirements;
  } catch (e) {
    print('Error fetching document requirements: $e');
    return [];
  }
}
