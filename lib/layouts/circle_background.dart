import 'package:flutter/material.dart';

import '../themes/colors.dart';

class CircleBackground extends StatelessWidget {
  final Widget? child;
  const CircleBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top right circle
          Positioned(
            top: -245,
            left: -161,
            child: Container(
              width: 361,
              height: 361,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: highlightColor
              ),
            ),
          ),
          Positioned(
            bottom: -275,
            right: -161,
            child: Container(
              width: 361,
              height: 361,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: highlightColor
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 0,
            child: Image.asset(
              'lib/assets/images/accent-1.png',
              width: 75,
              height: 75,
            ),
          ),
          Positioned(
            bottom: 35,
            left: 50,
            child: Image.asset(
              'lib/assets/images/accent-2.png',
              width: 75,
              height: 75,
            ),
          ),
          child!
        ],
      ),
    );
  }
}