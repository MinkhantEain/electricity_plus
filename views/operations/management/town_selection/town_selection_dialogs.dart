import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';
import 'package:electricity_plus/views/operations/management/town_selection/bloc/town_selection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showTownSelected(BuildContext context, String townName) async {
  return showGenericDialog(
    context: context,
    title: 'Town Changed',
    content: "Town has been changed to $townName",
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<void> showTownDelete(BuildContext context, String townName) async {
  return showGenericDialog(
    context: context,
    title: 'Town Deleted',
    content: "The $townName has been deleted",
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<void> showTownAdded(BuildContext context, String townName) async {
  return showGenericDialog(
    context: context,
    title: 'Town Added',
    content: "Town: $townName has been added",
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<void> showEmptyTownNameInput(BuildContext context) async {
  return showGenericDialog(
    context: context,
    title: 'Town Added Error',
    content: "Cannot be empty input.",
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<void> showTownDeleteConfirmation(BuildContext context, String townName) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Town Deletion',
    content:
        "Are you sure you want to delete $townName, all data associated with $townName will be lost.",
    optionsBuilder: () => {
      'No': false,
      'Yes': true,
    },
  ).then((value) => value ?? false).then((value) => value
      ? context
          .read<TownSelectionBloc>()
          .add(TownSelectionDelete(townName: townName))
      : null);
}
