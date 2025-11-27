import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> fetchDocumentRequirements(String documentName) async {
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

    return requirements;
  } catch (e) {
    print('Error fetching document requirements: $e');
    return [];
  }
}
