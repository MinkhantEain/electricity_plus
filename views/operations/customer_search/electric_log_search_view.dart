import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/views/operations/customer_list_view.dart';
import 'package:electricity_plus/views/operations/customer_search/bloc/customer_search_bloc.dart';
import 'package:electricity_plus/views/operations/electric_log/bloc/electric_log_bloc.dart';
import 'package:electricity_plus/views/operations/electric_log/create_new_electric_log_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ElectricLogSearchView extends StatefulWidget {
  const ElectricLogSearchView({super.key});

  @override
  State<ElectricLogSearchView> createState() => _ElectricLogSearchViewState();
}

class _ElectricLogSearchViewState extends State<ElectricLogSearchView> {
  late final TextEditingController _userInputTextController;

  Future<String> scanBarcode() async {
    String barCodeScanResult;
    try {
      barCodeScanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
    } on PlatformException {
      barCodeScanResult = '';
    }

    if (!mounted) {
      return '';
    }

    return barCodeScanResult;
  }

  @override
  void initState() {
    _userInputTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _userInputTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerSearchBloc, CustomerSearchState>(
      listener: (context, state) async {
        if (state is CustomerSearchLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is CustomerSearchError) {
            await showErrorDialog(
                context, 'Unexpected error occured. Contact admin');
          }
        }
      },
      builder: (context, state) {
        if (state is CustomerSearchInitial) {
          final customers = state.customers;
          return Scaffold(
            appBar: AppBar(
              title: const Text("Customer Search"),
              leading: BackButton(
                onPressed: () {
                  context
                      .read<OperationBloc>()
                      .add(const OperationEventDefault());
                },
              ),
              actions: [
                AppBarMenu(context),
              ],
            ),
            body: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _userInputTextController,
                        decoration: const InputDecoration(
                          hintText: 'BookID/MeterID:',
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                          final newText = await scanBarcode();
                          setState(() {
                            _userInputTextController.text = newText;
                          });
                          // ignore: use_build_context_synchronously
                          context.read<CustomerSearchBloc>().add(
                                CustomerSearch(
                                    userInput: _userInputTextController.text),
                              );
                        },
                        icon: const Icon(Icons.qr_code_scanner)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<CustomerSearchBloc>()
                            .add(const CustomerSearchReset());
                        _userInputTextController.clear();
                      },
                      child: const Text("Reset"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CustomerSearchBloc>().add(
                              CustomerSearch(
                                  userInput:
                                      _userInputTextController.text.trim()),
                            );
                      },
                      child: const Text("Search"),
                    ),
                  ],
                ),
                Expanded(
                  child: CustomerListView(
                    customers: customers,
                    onTap: (customer) {
                      context
                          .read<CustomerSearchBloc>()
                          .add(CustomerSearchCustomerSelectedEvent(
                            customer: customer,
                          ));
                    },
                  ),
                ),
              ],
            ),
          );
        } else if (state is CustomerSearchCustomerSelectedState) {
          return BlocProvider(
            create: (context) => ElectricLogBloc(FirebaseCloudStorage(), state.customer, state.previousReading),
            child: const CreateElectricLogView(),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
