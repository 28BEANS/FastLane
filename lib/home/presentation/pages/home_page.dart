import 'package:flutter/material.dart';
import '../../../core/widgets/navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavBar(title: 'Home'),
      body: const Center(
        child: Text('Welcome Home!'),
      ),
    );
  }

}
