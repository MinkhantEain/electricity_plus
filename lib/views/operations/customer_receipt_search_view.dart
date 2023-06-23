import 'package:electricity_plus/enums/menu_action.dart';
import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/home_page_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electricity_plus/views/operations/customer_list_view.dart';

class CustomerSearchView extends StatefulWidget {
  final Iterable<CloudCustomer>? cloudCustomers;
  const CustomerSearchView({super.key, this.cloudCustomers});

  @override
  State<CustomerSearchView> createState() => _CustomerSearchViewState();
}

class _CustomerSearchViewState extends State<CustomerSearchView> {
  late final TextEditingController _textController;

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
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperationBloc, OperationState>(
      listener: (context, state) async {
        if (state is OperationStateSearchingCustomerReceipt) {
          if (state.exception is CloudStorageException) {
            await showErrorDialog(context, 'Error has occured');
          }
        }
      },
      builder: (context, state) {
        state as OperationStateSearchingCustomerReceipt;
        Iterable<CloudCustomer> customers = state.customerIterable;
        return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () => context
                    .read<OperationBloc>()
                    .add(const OperationEventDefault()),
              ),
              title: const Text("Customer Bill"),
              actions: [AppBarMenu(context)],
            ),
            body: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'BookID/MeterID:',
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                          final newText = await scanBarcode();
                          setState(() {
                            _textController.text = newText;
                          });
                          context.read<OperationBloc>().add(
                                OperationEventCustomerReceiptSearch(
                                    isSearching: true,
                                    userInput: _textController.text),
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
                        context.read<OperationBloc>().add(
                              const OperationEventCustomerReceiptSearch(
                                  isSearching: true, userInput: ''),
                            );
                        _textController.clear();
                      },
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<OperationBloc>().add(
                              OperationEventCustomerReceiptSearch(
                                  isSearching: true,
                                  userInput: _textController.text),
                            );
                      },
                      child: const Text('Search'),
                    ),
                  ],
                ),
                Expanded(
                  flex: 5,
                  child: CustomerListView(
                    onTap: (customer) {
                      context
                          .read<OperationBloc>()
                          .add(OperationEventFetchCustomerReceiptHistory(
                            customer: customer,
                          ));
                    },
                    customers: customers,
                  ),
                )
              ],
            ));
      },
    );
  }

  
}
