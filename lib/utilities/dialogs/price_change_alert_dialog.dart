import 'package:flutter/material.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';

Future showPriceChangeAlertDialog(BuildContext context, String price) {
  return showGenericDialog(
    context: context,
    title: 'Price Change',
    content: "The per unit price has been changed to $price kyat",
    optionsBuilder: () => {
      'OK': Null,
    },
  );
}