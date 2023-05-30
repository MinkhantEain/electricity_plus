import 'package:flutter/material.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password Reset',
    content: "We have now sent you a password reset link, check your email for more information",
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}
