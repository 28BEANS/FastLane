import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/firebase_options.dart';
import 'pages/auth_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      home: const AuthPage(),
    );
  }
}