import 'package:flutter/material.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';

Future<bool> showFormErrorDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Form Error',
    content: "Need to complete the form",
    optionsBuilder: () => {
      'OK': null,
    },
  ).then(
    (value) => value ?? false,
  );
}

Future<void> showFormSubmittedDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Form Submission',
    content: "Your exchange meter form has been successfully submitted.",
    optionsBuilder: () => {
      'OK': null,
    },
  );
}