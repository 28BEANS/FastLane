import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createAccount({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String countryCode,
    String? middleName,
    String? country,
    String? region,
    String? city,
    String? street,
    String? postalCode,
    double? latitude,
    double? longitude,
  }) async {
    final UserCredential userCredential =
        await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    final User? user = userCredential.user;

    if (user != null) {
      await firestore.collection('users').doc(user.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'middleName': middleName ?? '',
        'countryCode': countryCode,
        'country': country ?? '',
        'region': region ?? '',
        'city': city ?? '',
        'street': street ?? '',
        'postalCode': postalCode ?? '',
        'lat': latitude,
        'lng': longitude,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signOut() async => await firebaseAuth.signOut();

  Future<void> resetPassword({required String email}) async =>
      await firebaseAuth.sendPasswordResetEmail(email: email);

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
