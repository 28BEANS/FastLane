/*
  AUTHENTICATION SERVICE (auth_service.dart)
    - Seperates the Authentication Functions from auth_page.dart into auth_service.dart with added features 
    - This keeps UI clean and readable 

    Information:
    - Email - String
    - Password - String

    Features:
    1. signIn
    2. createAccount
    3. signOut
    4. resetPassword
    5. deleteAccount
    6. resetPasswordFromCurrentPassword

    Author: Prince Pamintuan
    Created on: November 20, 2025

*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'; 

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

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
    String? middleName,
  }) async {
    final UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    final User? user = userCredential.user;

    if (user != null){
      await firestore.collection('users').doc(user.uid).set({
        'firstName' : firstName, 
        'lastName' : lastName,
        'middleName' : middleName ?? '',
        'email' : user.email,
        'createdAt' : FieldValue.serverTimestamp(),
      });
    }


  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({
    required String username,
  }) async {
    await currentUser!.updateDisplayName(username);
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = 
      EmailAuthProvider.credential(email: email, password: password);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = 
      EmailAuthProvider.credential(email: email, password: currentPassword);
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.updatePassword(newPassword);
  }


}
