import 'package:date_time_picker/date_time_picker.dart';
import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/views/operations/management/import_data/bloc/import_data_bloc.dart';
import 'package:electricity_plus/views/operations/management/import_data/import_data_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImportDataView extends StatefulWidget {
  const ImportDataView({super.key});

  @override
  State<ImportDataView> createState() => _ImportDataViewState();
}

class _ImportDataViewState extends State<ImportDataView> {
  String date = '';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImportDataBloc, ImportDataState>(
      listener: (context, state) async {
        if (state is ImportDataStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is ImportDataStateErrorFileNotChosenError) {
            await showErrorDialog(context, 'File not chosen');
          } else if (state is ImportDataStateChosenFileNotValidError) {
            await showErrorDialog(
                context, 'The chosen file is not of valid type.');
          } else if (state is ImportDataStateErrorDateNotChosenError) {
            await showErrorDialog(context, 'Date not selected');
          } else if (state is ImportDataStateError) {
            await showErrorDialog(
                context, 'Unaccounted error has occured. Report to admin');
          } else if (state is ImportDataStateDataImported) {
            await showDataImportCompleteDialogs(context);
          }
        }
      },
      builder: (context, state) {
        if (state is ImportDataStateInitial) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () async {
                  context
                      .read<OperationBloc>()
                      .add(const OperationEventAdminView());
                  await BlocProvider.of<ImportDataBloc>(context).close();
                },
              ),
              title: const Text("Initialise Data"),
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: DateTimePicker(
                        initialDate: DateTime.now(),
                        firstDate: DateTime.parse('0000-01-01'),
                        lastDate: DateTime.parse('9999-01-01'),
                        dateLabelText: 'Date of import data',
                        onChanged: (value) {
                          setState(() {
                            date = value;
                          });
                        },
                      ),
                    ),
                    Text(
                      'File Name: ${state is ImportDataStateFileChosen ? state.file.name : ''}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Text(
                        'File bytes: ${state is! ImportDataStateFileChosen ? '' : state.file.bytes}'),
                    Text(
                        'File extension: ${state is! ImportDataStateFileChosen ? '' : state.file.extension}'),
                    Text(
                      'File path: ${state is! ImportDataStateFileChosen ? '' : state.file.path}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                        'File size: ${state is! ImportDataStateFileChosen ? '' : state.file.size}'),
                    CustomButton(
                      title: 'Choose File',
                      icon: Icons.file_open,
                      onClick: () {
                        context
                            .read<ImportDataBloc>()
                            .add(const ImportDataEventChooseFile());
                      },
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (state is ImportDataStateFileChosen) {
                            context.read<ImportDataBloc>().add(
                                ImportDataEventSubmit(
                                    date: date, file: state.file));
                          } else {
                            context.read<ImportDataBloc>().add(
                                const ImportDataEventFileNotChosenSubmit());
                          }
                        },
                        child: const Text('Submit')),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
