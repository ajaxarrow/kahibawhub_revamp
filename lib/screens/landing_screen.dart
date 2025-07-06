import 'package:flutter/material.dart';
import '../themes/colors.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 20,
            right: 0,
            child: Image.asset(
              'lib/assets/images/accent-1.png',
              width: 75,
              height: 75,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20), // Adds some space to avoid overlap with the accent image
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'lib/assets/images/placeholder-logo.png',
                      width: 75,
                      height: 75,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center, // Centers horizontally
                    child: Image.asset(
                      'lib/assets/images/kahibawhub.png',
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "KahibawHub: Learning Materials Repository System",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "A centralized platform for storing, organizing, and accessing educational resources.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/auth');
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Set border radius here
                        ),
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 20), // Increases height
                      ),
                    child: const Text(
                      "Get Started!",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
