import 'dart:developer';

import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  Future<String> scanQRcode() async {
    String barCodeScanResult;
    try {
      barCodeScanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
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
  Widget build(BuildContext context) {
    return BlocBuilder<OperationBloc, OperationState>(
      builder: (context, state) {
        state as OperationStateDefault;
        log(state.staff.userType);
        return Scaffold(
          appBar: AppBar(
            actions: [
              AppBarMenu(context),
            ],
            title: Text("Town: ${state.townName}"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: state.townName != 'Town Not Chosen' &&
                        ([
                          meterReaderType,
                          cashierType,
                          managerType,
                          adminType,
                          directorType
                        ].contains(state.staff.userType)),
                    child: HomePageButton(
                      icon: const Icon(Icons.assignment_outlined),
                      text: "Read Meter",
                      onPressed: () {
                        context
                            .read<OperationBloc>()
                            .add(const OperationEventElectricLog());
                      },
                    ),
                  ),
                  Visibility(
                    visible: state.townName != 'Town Not Chosen' &&
                        ([
                          meterReaderType,
                          cashierType,
                          managerType,
                          adminType,
                          directorType
                        ].contains(state.staff.userType)),
                    child: HomePageButton(
                      icon: const Icon(Icons.history_edu_outlined),
                      text: "Bill History",
                      onPressed: () {
                        context
                            .read<OperationBloc>()
                            .add(const OperationEventBillHistory());
                      },
                    ),
                  ),
                  Visibility(
                    visible: state.townName != 'Town Not Chosen' &&
                        ([
                          meterReaderType,
                          cashierType,
                          managerType,
                          adminType,
                          directorType
                        ].contains(state.staff.userType)),
                    child: HomePageButton(
                      icon: const Icon(Icons.flag_outlined),
                      text: "Flagged",
                      onPressed: () {
                        context
                            .read<OperationBloc>()
                            .add(const OperationEventFlagged());
                      },
                    ),
                  ),
                  Visibility(
                    visible: state.townName != 'Town Not Chosen' &&
                        ([cashierType, managerType, adminType, directorType]
                            .contains(state.staff.userType)),
                    child: HomePageButton(
                      icon: const Icon(Icons.payments_outlined),
                      text: "Make Payment",
                      onPressed: () async {
                        //scans qr code then redirect to receipt page;
                        final qrCode = await scanQRcode();
                        if (qrCode != '-1') {
                          // ignore: use_build_context_synchronously
                          context
                              .read<OperationBloc>()
                              .add(OperationEventPayment(qrCode: qrCode));
                        }
                      },
                    ),
                  ),
                  Visibility(
                    visible: ([
                      cashierType,
                      managerType,
                      adminType,
                      directorType
                    ].contains(state.staff.userType)),
                    child: HomePageButton(
                      icon: const Icon(Icons.assignment_ind_outlined),
                      text: "Management",
                      onPressed: () {
                        context
                            .read<OperationBloc>()
                            .add(const OperationEventAdminView());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
