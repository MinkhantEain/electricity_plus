import 'package:flutter/material.dart';

Future<void> showGenericDialog(BuildContext context, String titleText, String contentText) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titleText),
          content: Text(contentText),
          actions: [
            TextButton(
              child: const Text("okay"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
}
