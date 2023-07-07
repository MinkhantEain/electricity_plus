import 'dart:typed_data';

import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/bill_receipt_bloc.dart';
import 'package:electricity_plus/views/operations/printer_select_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
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
    return BlocBuilder<BillReceiptBloc, BillReceiptState>(
      builder: (context, state) {
        if (state is BillReceiptPaymentState) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Receipt'),
              leading: BackButton(
                onPressed: () {
                  context
                      .read<OperationBloc>()
                      .add(const OperationEventDefault());
                },
              ),
            ),
            body: Column(
              children: [
                Screenshot(
                  controller: screenshotController,
                  child: Column(
                    children: [
                      const Text(
                        'Phoe Thee Cho Co.,Ltd',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        state.receipt.townName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.receipt.forDate),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text(
                            'ငွေရပြေစာ',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Text(
                        state.receipt.customerName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        state.receipt.bookId,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        state.receipt.transactionDate,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cash Collected by',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                const Text(
                                  'Meter Read Date',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                const Text(
                                  'Last Date',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                const Text(
                                  'Receipt No.',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                const Text(
                                  'Bill No.',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                Visibility(
                                    visible:
                                        (state.receipt.meterAllowance != 0),
                                    child: const Text(
                                      'Meter Allowance',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                    )),
                                Visibility(
                                  visible: (state.receipt.meterAllowance != 0),
                                  child: const Text(
                                    'Initial Cost',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Text(state.receipt.costOutputType()),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  state.receipt.collectorName,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  state.receipt.meterReadDate,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  state.receipt.paymentDueDate,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  state.receipt.receiptNo(),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  state.receipt.documentId,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                Visibility(
                                  visible: (state.receipt.meterAllowance != 0),
                                  child: Text(
                                    state.receipt.meterAllowance.toString(),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Text(state.receipt.initialCost.toString()),
                                Visibility(
                                  visible: (state.receipt.meterAllowance != 0),
                                  child: Text(
                                    state.receipt.finalCostCalculation(),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
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
                          context.read<BillReceiptBloc>().add(
                              ReceiptPrinterConnectEvent(
                                  customer: state.customer,
                                  history: state.history,
                                  receipt: state.receipt));
                        }
                      });
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(Icons.print_outlined),
                      SizedBox(width: 2,),
                      Text('Print'),
                    ]),
                  ),
                ),
              ],
            ),
          );
        } else if (state is ReceiptPrinterNotConnected) {
          return const PrinterSelectView();
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
