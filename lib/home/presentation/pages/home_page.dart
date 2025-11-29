import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a Scaffold here to support Drawers or Snackbars specific to Home,
    // but we DO NOT add the BottomNavigationBar here.
    return const Scaffold(
      backgroundColor: Colors.transparent, // Matches the Shell's background
      body: Center(
        child: Text(
          'Welcome Home!',
          style: TextStyle(color: Colors.black),),
        
      ),
    );
  }
}