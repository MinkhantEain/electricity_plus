import 'dart:developer' as dev show log;

import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/utilities/dialogs/electric_log_dialogs.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/views/operations/customer_search/bloc/customer_search_bloc.dart';
import 'package:electricity_plus/views/operations/electric_log/bloc/electric_log_bloc.dart';
import 'package:electricity_plus/views/operations/electric_log/electric_log_next_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateElectricLogView extends StatefulWidget {
  const CreateElectricLogView({super.key});

  @override
  State<CreateElectricLogView> createState() => _CreateElectricLogViewState();
}

class _CreateElectricLogViewState extends State<CreateElectricLogView> {
  late final TextEditingController _newReadingTextController;

  @override
  void initState() {
    _newReadingTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _newReadingTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ElectricLogBloc, ElectricLogState>(
      listener: (context, state) async {
        dev.log(state.toString());
        if (state is ElectricLogLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is ELectricLogErrorInvalidInput) {
            await showInvalidInputDialog(context, state.invalidInput);
          } else if (state is ELectricLogErrorEmptyInput) {
            await showEmptyInputErrorDialog(context);
          } else if (state is ElectricLogErrorUnableToUpload) {
            await showUnableToUploadDialog(context);
          } else if (state is ELectricLogErrorUnableToUpdate) {
            await showUnableToUpdateDialog(context);
          } else if (state is ElectricLogError) {
            await showGenericLogErrorDialog(context);
          } else if (state is ElectricLogSubmitted) {
            ///goes to bill view on clicking submit
            await showLogSubmittedDialog(context, customer: state.customer, history: state.history );
          }
        }
      },
      builder: (context, state) {
        if (state is ElectricLogForm) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () async {
                  context
                      .read<CustomerSearchBloc>()
                      .add(const CustomerSearchReset());
                  await BlocProvider.of<ElectricLogBloc>(context).close();
                },
              ),
              title: const Text("New Electric Log"),
            ),
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("BookID: "),
                    Flexible(
                      fit: FlexFit.loose,
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: state.customer.bookId.toString()),
                        enabled: false,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("MeterID: "),
                    Flexible(
                      fit: FlexFit.loose,
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: state.customer.meterId.toString()),
                        enabled: false,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Name: "),
                    Flexible(
                      fit: FlexFit.loose,
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: state.customer.name.toString()),
                        enabled: false,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Address: "),
                    Flexible(
                      fit: FlexFit.loose,
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: state.customer.address.toString()),
                        enabled: false,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Previous Reading: "),
                    Flexible(
                      fit: FlexFit.loose,
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: state.previousReading),
                        enabled: false,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("New Reading: "),
                    Flexible(
                      fit: FlexFit.loose,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'New Reading',
                        ),
                        controller: _newReadingTextController,
                        enabled: true,
                      ),
                    )
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_newReadingTextController.text.isEmpty) {
                      await showErrorDialog(
                          context, "New Reading cannot be empty!");
                    } else if (_newReadingTextController.text.contains('.') ||
                        _newReadingTextController.text.contains('-')) {
                      await showErrorDialog(
                          context, "having . and - are invalid input!");
                    } else {
                      context.read<ElectricLogBloc>().add(ElectricLogNextPage(
                          newReading: _newReadingTextController.text,
                          customer: state.customer));
                    }
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          );
        } else if (state is ELectricLogFormNextPage) {
          return const ELectricLogNextPageView();
        } else {
          return const Scaffold();
        }
      },
    );
  }
}


