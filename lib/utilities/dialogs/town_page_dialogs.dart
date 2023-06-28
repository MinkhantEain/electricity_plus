import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';



Future<void> showTownSelected(BuildContext context, String townName) async {
   return showGenericDialog(
    context: context,
    title: 'Town Changed',
    content: "Town has been changed to $townName",
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}


Future<void> showTownDelete(BuildContext context, String townName) async {
   return showGenericDialog(
    context: context,
    title: 'Town Deleted',
    content: "The $townName has been deleted",
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}

Future<void> showTownAdded(BuildContext context, String townName) async {
   return showGenericDialog(
    context: context,
    title: 'Town Added',
    content: "Town: $townName has been added",
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}