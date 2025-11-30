import 'package:flutter/material.dart';

class GlobalHeader extends StatelessWidget {
  const GlobalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 175,
      color: Colors.blue,
      padding: const EdgeInsets.only(left: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Transform.translate(
            offset: Offset(0, 50),
            child: Text(
              'Juan de la Cruz',
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),

          SizedBox(height: 5),

          // Email
          Transform.translate(
            offset: Offset(0, 40),
            child: Text(
              'juandelacruz@email.com',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),

          SizedBox(height: 5),

          // Employment status
          Transform.translate(
            offset: Offset(30, 40),
            child: Text(
              'Unemployed',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
