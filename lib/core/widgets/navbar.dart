import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.home,
      Icons.checklist,
      Icons.chat_bubble_outline,
      Icons.map,
      Icons.logout,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Center(
        child: Container(
          height: 70,
          width: 330, // Fixed width container matches your pixel logic
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Sliding Highlight
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                // Warning: This hardcoded math relies on specific padding/width.
                // If you change the width (330), you must recalibrate this.
                left: 15.0 + (currentIndex * 63.0),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(icons.length, (index) {
                  final isActive = index == currentIndex;
                  return GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque, // Ensures tap target is solid
                    child: SizedBox( // Ensure consistent hit area
                      height: 48,
                      width: 48,
                      child: Icon(
                        icons[index],
                        color: isActive ? Colors.black : Colors.white,
                        size: isActive ? 26 : 24,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}