import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/controllers/nav_controller.dart';
import '../../core/widgets/navbar.dart';
import '../../home/presentation/pages/home_page.dart';
import '../../chatbot/presentation/pages/chatbot_page.dart';
// Import your other pages here

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the controller locally if it's not needed globally
    return ChangeNotifierProvider(
      create: (_) => NavController(),
      child: const _MainShellView(),
    );
  }
}

class _MainShellView extends StatelessWidget {
  const _MainShellView();

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavController>();

    final List<Widget> pages = [
      const HomePage(),
      const Scaffold(body: Center(child: Text("Checklist"))), // Placeholder
      const ChatbotPage(),
      const Scaffold(body: Center(child: Text("Maps"))), // Placeholder
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF0F5FF),
      // IndexedStack preserves the state of the pages (doesn't rebuild them when switching)
      body: IndexedStack(
        index: nav.currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: nav.currentIndex,
        onTap: (index) {
          if (index == 4) {
            nav.handleLogout(context);
          } else {
            nav.setIndex(index);
          }
        },
      ),
    );
  }
}