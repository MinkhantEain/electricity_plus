import 'dart:typed_data';

import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/receipt_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  var printerManager = PrinterManager.instance;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    var f = NumberFormat('#,###,###,###,###,###', 'en_US');
    return BlocBuilder<ReceiptBloc, ReceiptState>(
      builder: (context, state) {
        if (state is ReceiptStateReceiptView) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Receipt'),
              leading: BackButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop([state.customer, state.customerHistory]);
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Screenshot(
                    controller: screenshotController,
                    child: Column(
                      children: [
                        const Text(
                          'Electricity Plus Co.,Ltd',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          state.receipt.townName,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.receipt.forDate,
                              style: const TextStyle(fontSize: 17),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              'Receipt',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Text(
                          state.receipt.customerName,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          state.receipt.bookId,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          state.receipt.transactionDate.substring(0, 10),
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Payment Collector',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                FirebaseAuth.instance.currentUser!.displayName!,
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Payment Method',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                state.receipt.paymentMethod,
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: state.receipt.paymentMethod == 'Bank',
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Bank (online)',
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  state.receipt.bank,
                                  style: const TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: state.receipt.paymentMethod == 'Bank',
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Transaction ID',
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  state.receipt.transactionId,
                                  style: const TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: state.receipt.paymentMethod == 'Bank',
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Transaction Date',
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  state.receipt.bankTransactionDate,
                                  style: const TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'For Date',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                state.receipt.forDate,
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Meter Read Date',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                state.receipt.meterReadDate.substring(0, 10),
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Meter ID',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                state.customer.meterId,
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Unit Used',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                f.format(state.customerHistory.getUnitUsed()),
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'ELectricity Unit Price',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                f.format(state.receipt.priceAtm),
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: state.customerHistory.meterAllowance != 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Meter Allowance',
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  f.format(state.customerHistory.meterAllowance),
                                  style: const TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Cost',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                f.format(state.customerHistory.cost),
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Cash Collected',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                f.format(state.receipt.paidAmount),
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Left Over',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                f.format(state.customerHistory.unpaidAmount()),
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.2,
                    child: ElevatedButton(
                      onPressed: () async {
                        screenshotController
                            .capture()
                            .then((capturedImage) async {
                          capturedImage as Uint8List;
                          if (printerManager.currentStatusBT ==
                              BTStatus.connected) {
                            await printReceipt(capturedImage, printerManager);
                          } else {
                            context.read<ReceiptBloc>().add(
                                ReceiptEventConnectPrinter(resumeState: state));
                          }
                        });
                      },
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.print_outlined),
                            SizedBox(
                              width: 2,
                            ),
                            Text('Print'),
                          ]),
                    ),
                  ),
                ],
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
