import 'dart:developer' as dev show log;

import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/utilities/dialogs/electric_log_dialogs.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/views/operations/customer_search/bloc/customer_search_bloc.dart';
import 'package:electricity_plus/views/operations/flagged/bloc/flagged_bloc.dart';
import 'package:electricity_plus/views/operations/read_meter/bloc/read_meter_bloc.dart';
import 'package:electricity_plus/views/operations/read_meter/flag_customer_view.dart';
import 'package:electricity_plus/views/operations/read_meter/read_meter_second_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReadMeterFirstPage extends StatefulWidget {
  final Iterable<CloudCustomer>? customers;
  final String? fromPage;
  const ReadMeterFirstPage({super.key, this.fromPage, this.customers});

  @override
  State<ReadMeterFirstPage> createState() => _ReadMeterFirstPageState();
}

class _ReadMeterFirstPageState extends State<ReadMeterFirstPage> {
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
    return BlocConsumer<ReadMeterBloc, ReadMeterState>(
      listener: (context, state) async {
        dev.log(state.toString());
        if (state is ReadMeterStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is ReadMeterStateErrorInvalidInput) {
            await showInvalidInputDialog(context, state.invalidInput);
          } else if (state is ReadMeterStateErrorEmptyInput) {
            await showEmptyInputErrorDialog(context);
          } else if (state is ReadMeterStateErrorUnableToUpload) {
            await showUnableToUploadDialog(context);
          } else if (state is ReadMeterStateErrorUnableToUpdate) {
            await showUnableToUpdateDialog(context);
          } else if (state is ReadMeterStateError) {
            await showGenericLogErrorDialog(context);
          } else if (state is ReadMeterStateSubmitted) {
            ///goes to bill view on clicking submit
            await showLogSubmittedDialog(context,
                customer: state.customer, history: state.history);
          } else if (state is ReadMeterStateFlagReportSubmitted) {
            await showFlagReportSubmittedDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is ReadMeterStateFirstPage) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () async {
                  if (widget.fromPage == 'Unread Customers') {
                    context.read<FlaggedBloc>().add(FlaggedEventUnreadCustomers(
                        customers: widget.customers));
                  } else {
                    context
                        .read<CustomerSearchBloc>()
                        .add(const CustomerSearchMeterReadSearchInitialise());
                  }

                  await BlocProvider.of<ReadMeterBloc>(context).close();
                },
              ),
              title: const Text("New Electric Log"),
              actions: [
                IconButton(
                  onPressed: () {
                    context.read<ReadMeterBloc>().add(ReadMeterEventFlagReport(
                          customer: state.customer,
                        ));
                  },
                  icon: const Icon(Icons.flag_sharp),
                  color: Colors.red,
                  iconSize: 40,
                ),
              ],
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
                        decoration:
                            InputDecoration(hintText: state.previousReading),
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
                          hintText: '????????',
                          
                        ),
                        controller: _newReadingTextController,
                        enabled: !state.customer.flag,
                      ),
                    )
                  ],
                ),
                Visibility(
                  visible: !state.customer.flag,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_newReadingTextController.text.isEmpty) {
                        await showErrorDialog(
                            context, "New Reading cannot be empty!");
                      } else if (_newReadingTextController.text.contains('.') ||
                          _newReadingTextController.text.contains('-')) {
                        await showErrorDialog(
                            context, "having . and - are invalid input!");
                      } else {
                        context.read<ReadMeterBloc>().add(
                            ReadMeterEventSecondPage(
                                newReading: _newReadingTextController.text,
                                customer: state.customer));
                      }
                    },
                    child: const Text('Next'),
                  ),
                ),
                Visibility(
                    visible: state.customer.flag,
                    child: ElevatedButton(
                      child: const Text('Resolve Flag'),
                      onPressed: () {
                        //TODO: redirect to resolve issue with the customer.
                      },
                    ))
              ],
            ),
          );
        } else if (state is ReadMeterStateSecondPage) {
          return const ReadMeterSecondPageView();
        } else if (state is ReadMeterStateFlagReport) {
          return const FlagCustomerView();
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
