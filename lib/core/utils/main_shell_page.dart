import 'package:flutter/material.dart';
import 'package:yourapp/core/utils/nav_controller.dart';
import 'package:yourapp/core/widgets/navbar.dart';

class MainShellPage extends StatefulWidget {
  final Widget child;

  const MainShellPage({super.key, required this.child});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late NavigationController nav;

  @override
  void initState() {
    super.initState();
    nav = NavigationController();
    nav.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F5FF),
      body: widget.child,
      bottomNavigationBar: CustomNavbar(
        currentIndex: nav.currentIndex,
        onTap: (i) => nav.handleTap(context, i),
      ),
    );
  }
}
