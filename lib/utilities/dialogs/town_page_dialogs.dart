import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showTownChangeDialog(BuildContext context, String townName) async {
   return showGenericDialog(
    context: context,
    title: 'Town Changed',
    content: "Town has been changed to $townName",
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}


Future<void> showTownDelete(BuildContext context) async {
   return showGenericDialog(
    context: context,
    title: 'Town Deleted',
    content: "The town has been deleted",
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}

Future<void> showTownAdded(BuildContext context, String townName) async {
   return showGenericDialog(
    context: context,
    title: 'Town Deleted',
    content: "Town: $townName has been deleted",
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}