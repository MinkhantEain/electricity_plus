
import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:electricity_plus/views/operations/customer_list_view.dart';
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
    return BlocConsumer<OperationBloc, OperationState>(
      listener: (context, state) {
      },
      builder: (context, state) {
        state as OperationStateElectricLogSearch;
        Iterable<CloudCustomer> customers = state.customerIterable;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Electric Log Search"),
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
                          context.read<OperationBloc>().add(
                            OperationEventElectricLogSearch(
                                isSearching: true,
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
                      context.read<OperationBloc>().add(
                            const OperationEventElectricLogSearch(
                                isSearching: false, userInput: ''),
                          );
                      _userInputTextController.clear();
                    },
                    child: const Text("Reset"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<OperationBloc>().add(
                            OperationEventElectricLogSearch(
                                isSearching: true,
                                userInput: _userInputTextController.text),
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
                        .read<OperationBloc>()
                        .add(OperationEventCreateNewElectricLog(
                          newReading: '',
                          customer: customer,
                        ));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
