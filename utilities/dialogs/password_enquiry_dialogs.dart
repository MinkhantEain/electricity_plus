import 'package:electricity_plus/helper/password_enquiry/password_enquiry_overlay.dart';
import 'package:flutter/material.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';

Future<void> showWrongPasswordErrrDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Wrong Password',
    content: "The password you have entered is wrong.",
    optionsBuilder: () => {
      'OK': null,
    },
  ).then((value) {
    PasswordEnquiry().hide();
  });
}