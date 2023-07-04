import 'package:flutter/material.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';

Future<bool> showHomePageDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Go Home',
    content: "Go to home page?",
    optionsBuilder: () => {
      'Cancel': false,
      'Go to Home Page': true,
    },
  ).then(
    (value) => value ?? false,
  );
}