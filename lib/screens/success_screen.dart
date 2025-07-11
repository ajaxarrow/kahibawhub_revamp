import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../themes/colors.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    super.key, 
    required this.description, 
    required this.buttonContent, 
    required this.path
  });
  
  final String description;
  final String buttonContent;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const PhosphorIcon(
            PhosphorIconsFill.caretCircleLeft,
            color: primaryColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Keeps content centered
                    children: [
                      const PhosphorIcon(
                        PhosphorIconsFill.sealCheck,
                        color: primaryColor,
                        size: 150,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Success!',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(path);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: Text(
                    buttonContent,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Adds space between button and bottom
            ],
          ),
        ),
      ),
    );
  }
}
