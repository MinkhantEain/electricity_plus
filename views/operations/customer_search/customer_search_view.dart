import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/views/operations/bill_history/bloc/bill_history_bloc.dart';
import 'package:electricity_plus/views/operations/bill_history/bill_history_view.dart';
import 'package:electricity_plus/views/operations/customer_search/bloc/customer_search_bloc.dart';
import 'package:electricity_plus/views/operations/management/exchange_meter/bloc/exchange_meter_bloc.dart';
import 'package:electricity_plus/views/operations/management/exchange_meter/exchange_meter_view.dart';
import 'package:electricity_plus/views/operations/read_meter/bloc/read_meter_bloc.dart';
import 'package:electricity_plus/views/operations/read_meter/read_meter_first_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as dev show log;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerSearchView extends StatefulWidget {
  const CustomerSearchView({super.key});

  @override
  State<CustomerSearchView> createState() => _CustomerSearchViewState();
}

class _CustomerSearchViewState extends State<CustomerSearchView> {
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
          if (state is CustomerSearchNotFoundError) {
            await showErrorDialog(
                context, 'User not found, make sure the bookID is correct.');
          } else if (state is CustomerSearchMeterReadAlreadyReadAndPaid) {
            await showErrorDialog(context, 'Customer has been read and paid for the month');
          } else if (state is CustomerSearchMeterReadExchangeMeterWasDone) {
            await showErrorDialog(context, 'Exchange meter was done, cannot read this month.');
          } else if (state is CustomerSearchError) {
            await showErrorDialog(
                context, 'Unexpected error occured. Contact admin');
          }
        }
      },
      builder: (context, state) {
        dev.log(state.toString());
        if (state is CustomerSearchInitial) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.pageName),
              leading: BackButton(
                onPressed: () async {
                  context
                      .read<OperationBloc>()
                      .add(const OperationEventDefault());
                  await BlocProvider.of<CustomerSearchBloc>(context).close();
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
                          hintText: 'BookID...:',
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
                                CustomerSearchEventSearch(
                                  userInput: _userInputTextController.text.trim(),
                                  pageName: state.pageName,
                                ),
                              );
                        },
                        icon: const Icon(Icons.qr_code_scanner)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<CustomerSearchBloc>().add(
                              CustomerSearchEventSearch(
                                  userInput:
                                      _userInputTextController.text.trim(),
                                  pageName: state.pageName),
                            );
                      },
                      child: const Text("Search"),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else if (state is CustomerSearchMeterReadSearchSuccessful) {
          return BlocProvider(
            create: (context) => ReadMeterBloc(FirebaseCloudStorage(),
                state.customer, state.previousUnit.toString()),
            child: const ReadMeterFirstPage(),
          );
        } else if (state is CustomerSearchBillHistorySearchSuccessful) {
          return BlocProvider(
            create: (context) => BillHistoryBloc(
                historyList: state.historyList, customer: state.customer),
            child: const BillHistoryView(),
          );
        } else if (state is CustomerSearchExchangeMeterSearchSuccessful) {
          return BlocProvider(
            create: (context) => ExchangeMeterBloc(
                provider: FirebaseCloudStorage(), customer: state.customer),
            child: const ExchangeMeterView(),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
