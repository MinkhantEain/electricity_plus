
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showEmailVerificationSendDialogs(BuildContext context) async {
  return showGenericDialog(
    context: context,
    title: 'Email Verification Link Sent',
    content: """Email Verification link has been sent to your email. 
Please open the link in email to verify in order to log in.""",
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<void> showPasswordReEntryErrorDialogs(BuildContext context) async {
  return showGenericDialog(
    context: context,
    title: 'Password Re-Entry Error',
    content: 'The password fields are not the same. Please redo.',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
