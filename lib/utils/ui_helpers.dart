import 'package:flutter/material.dart';

void showError({
  required BuildContext context,
  required String errorMessage,
  required String errorTitle,
}) {
  print('showError called'); // Debug print
  print('Current context: $context'); // Debug print

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(errorTitle),
      content: Text(errorMessage),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
          },
          child: const Text('Okay'),
        )
      ],
    ),
  );
}