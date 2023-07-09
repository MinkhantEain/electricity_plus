import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';
import 'package:electricity_plus/views/operations/management/import_data/bloc/import_data_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showDataImportCompleteDialogs(BuildContext context) async {
  return showGenericDialog(
    context: context,
    title: 'Import Completed',
    content: 'Import completed! The bill history and customer can now be accessed.',
    optionsBuilder: () => {
      'OK': null,
    },
  ).then((value) => context.read<ImportDataBloc>().add(const ImportDataEventReinitialisePage()));
}