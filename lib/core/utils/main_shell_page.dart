import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/controllers/nav_controller.dart';
import '../../core/widgets/navbar.dart';
import '../../core/widgets/header.dart';
import '../../home/presentation/pages/home_page.dart';
import '../../chatbot/presentation/pages/chatbot_page.dart';
import '../../checklist/presentation/pages/checklist_page.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _MainShellView(); // non-const to allow rebuilds
  }
}

class _MainShellView extends StatelessWidget {
  const _MainShellView();

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavController>();

    final List<Widget> pages = [
      const HomePage(),                       // stateless, can be const
      ChecklistPage(),                  // depends on provider, must NOT be const
      ChatbotPage(),                           // depends on provider, must NOT be const
      const Scaffold(body: Center(child: Text("Maps"))),      // static
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF0F5FF),
      body: Stack(
        children: [
            Column(
              children: [
                const GlobalHeader(),
                
                // Fill space below the navbar
                Expanded(
                  child: IndexedStack(
                  index: nav.currentIndex,
                  children: pages.map((page) => SizedBox.expand(child: page)).toList(),
                  ),
                ),
              ],
            ),

          // Align navbar at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CustomNavbar(
                currentIndex: nav.currentIndex,
                onTap: (index) {
                  if (index == pages.length) {
                    nav.handleLogout(context);
                  } else if (index < pages.length) {
                    nav.setIndex(index);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}