import 'package:flutter/material.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';

Future showPriceChangeAlertDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Price Change',
    content: "The prices have been changed",
    optionsBuilder: () => {
      'OK': Null,
    },
  );
}

Future showPriceUnhangeAlertDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Price unchanged',
    content: "The prices are unchanged",
    optionsBuilder: () => {
      'OK': Null,
    },
  );
}