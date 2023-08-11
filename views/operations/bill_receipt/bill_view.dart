import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bill_receipt_dialogs.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/bill_bloc.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/receipt_bloc.dart';
import 'package:electricity_plus/views/operations/bill_receipt/receipt_frame.dart';
import 'package:electricity_plus/views/operations/printer_select_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

class BillView extends StatefulWidget {
  const BillView({
    super.key,
  });

  @override
  State<BillView> createState() => _BillViewState();
}

class _BillViewState extends State<BillView> {
  ScreenshotController screenshotController = ScreenshotController();
  var printerManager = PrinterManager.instance;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillBloc, BillState>(
      listener: (context, state) async {
        if (state is BillStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is BillStateNotFoundError) {
            await showNoHistoryDocumentErrorDialog(context);
          } else if (state is BillStatePrinterNotConnected) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const PrinterSelectView(),
            ));
          } else if (state is BillStateMakePayment) {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) =>
                          ReceiptBloc(provider: FirebaseCloudStorage())
                            ..add(
                              ReceiptEventPaymentDetailAcquisition(
                                customer: state.customer,
                                customerHistory: state.customerHistory,
                              ),
                            ),
                      child: const ReceiptFrameView(),
                    ),
                  ),
                )
                .then((value) => Navigator.of(context).pop(value));
          } else if (state is BillStateReopenReceipt) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) =>
                    ReceiptBloc(provider: FirebaseCloudStorage())
                      ..add(ReceiptEventReopenReceipt(
                        customer: state.customer,
                        customerHistory: state.customerHistory,
                      )),
                child: const ReceiptFrameView(),
              ),
            ));
          } else if (state is BillStateInvalidMeterAllowance) {
            await showInvalidAllowanceErrorDialog(context, state.errorMessage);
          }
        }
      },
      builder: (context, state) {
        if (state is BillInitialised) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () async {
                  Navigator.of(context).pop([state.customer, state.history]);
                },
              ),
              title: const Text("Bill"),
              actions: [
                Visibility(
                  visible: !state.history.isPaid,
                  child: IconButton(
                      onPressed: () async {
                        await showAskForMeterAllowanceDialog(context).then(
                            (value) => context.read<BillBloc>().add(
                                BillEventMeterAllowanceRecliberation(
                                    customer: state.customer,
                                    customerHistory: state.history,
                                    meterAllowance: value,
                                    historyList: state.historyList)));
                      },
                      icon: const Icon(Icons.settings)),
                )
              ],
            ),
            body: Row(
              children: [
                SingleChildScrollView(
                    child: Column(
                  children: [
                    Bill(
                      phoneScreenSize: MediaQuery.sizeOf(context),
                      customer: state.customer,
                      history: state.history,
                      historyList: state.historyList,
                    ),
                    Row(
                      children: [
                        Visibility(
                          visible: !state.history.isVoided,
                          child: ElevatedButton(
                            child: const Text('Print'),
                            onPressed: () {
                              if (printerManager.currentStatusBT ==
                                  BTStatus.connected) {
                                screenshotController
                                    .captureFromLongWidget(
                                  InheritedTheme.captureAll(
                                    context,
                                    Material(
                                      child: Bill(
                                        phoneScreenSize:
                                            MediaQuery.sizeOf(context),
                                        customer: state.customer,
                                        history: state.history,
                                        historyList: state.historyList,
                                      ),
                                      // billWidget(state.customer, state.history),
                                    ),
                                  ),
                                  context: context,
                                )
                                    .then((capturedImage) async {
                                  await printBillReceipt(
                                      capturedImage,
                                      printerManager,
                                      state.customer,
                                      state.history);
                                });
                              } else {
                                context
                                    .read<BillBloc>()
                                    .add(BillEventConnectPrinter(
                                      resumeState: state,
                                    ));
                              }
                            },
                          ),
                        ),
                        Visibility(
                            visible: !state.history.isPaid &&
                                !state.history.isVoided,
                            child: ElevatedButton(
                              child: const Text('Make Payment'),
                              onPressed: () {
                                context.read<BillBloc>().add(
                                      BillEventMakePayment(
                                        customer: state.customer,
                                        customerHistory: state.history,
                                      ),
                                    );
                              },
                            )),
                        Visibility(
                            visible:
                                state.history.isPaid && !state.history.isVoided,
                            child: ElevatedButton(
                              child: const Text('Receipt'),
                              onPressed: () {
                                context.read<BillBloc>().add(
                                      BillEventReopenReceipt(
                                        customer: state.customer,
                                        customerHistory: state.history,
                                      ),
                                    );
                              },
                            ))
                      ],
                    )
                  ],
                ))
              ],
            ),
          );
        } else if (state is BillStateReopenReceipt) {
          return BlocProvider(
            create: (context) => ReceiptBloc(provider: FirebaseCloudStorage())
              ..add(
                ReceiptEventReopenReceipt(
                  customer: state.customer,
                  customerHistory: state.customerHistory,
                ),
              ),
            child: const ReceiptFrameView(),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}

class Bill extends StatelessWidget {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  final Iterable<CloudCustomerHistory> historyList;
  final Size phoneScreenSize;
  const Bill({
    super.key,
    required this.customer,
    required this.history,
    required this.phoneScreenSize,
    required this.historyList,
  });

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat('#,###,###,###,###,###', 'en_US');
    return Column(
      children: [
        const Column(
          children: [
            SizedBox(
              height: 18,
            ),
            SizedBox(
              width: 325,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Electricity Plus Co.Ltd',
                        style: TextStyle(
                          fontSize: 18,fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Electricity Bill',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Text(
          customer.name,
          style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w900),
        ),
        Text(
          customer.address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w500),
        ),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BookID',
                style: TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
              Text(
                customer.bookId,
                style: const TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w900
                ),
              ),
            ],
          ),
        ),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Month',
                style: TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
              Text(
                monthYearWordFormat(history.date),
                style: const TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Date',
                style: TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
              Text(
                dayMonthYearNumericFormat(history.date),
                style: const TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Meter ID',
                style: TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
              Text(
                customer.meterId,
                style: const TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Previous Unit',
                style: TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
              Text(
                f.format(history.previousUnit),
                style: const TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Unit',
                style: TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
              Text(
                f.format(history.newUnit),
                style: const TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: history.meterMultiplier != 1,
          child: Container(
            width: phoneScreenSize.width,
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Unit Multiplier',
                  style: TextStyle(
                    fontSize: 18,fontWeight: FontWeight.w500
                  ),
                ),
                Text(
                  history.meterMultiplier.toString(),
                  style: const TextStyle(
                    fontSize: 18,fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Unit Used',
                style: TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
              Text(
                f.format(history.getUnitUsed()),
                style: const TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: history.meterAllowance != 0,
          child: Container(
            width: phoneScreenSize.width,
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meter Allowance',
                  style: TextStyle(
                    fontSize: 18,fontWeight: FontWeight.w500
                  ),
                ),
                Text(
                  f.format(history.meterAllowance),
                  style: const TextStyle(
                    fontSize: 18,fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: customer.horsePowerUnits != 0,
          child: Container(
            width: phoneScreenSize.width,
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HorsePower',
                  style: TextStyle(
                    fontSize: 18,fontWeight: FontWeight.w500
                  ),
                ),
                Text(
                  customer.horsePowerUnits.toString(),
                  style: const TextStyle(
                    fontSize: 18,fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Electric unit price',
                style: TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
              Text(
                f.format(history.priceAtm),
                style: const TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'cost',
                style: TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
              Text(
                f.format(history.getCost()),
                style: const TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: customer.hasRoadLightCost,
          child: Container(
            width: phoneScreenSize.width,
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Road Light Price',
                  style: TextStyle(
                    fontSize: 18,fontWeight: FontWeight.w500
                  ),
                ),
                Text(
                  f.format(customer.hasRoadLightCost
                      ? history.roadLightPrice
                      : 0),
                  style: const TextStyle(
                    fontSize: 18,fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Service Charge',
                style: TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
              Text(
                f.format(history.serviceChargeAtm),
                style: const TextStyle(
                  fontSize: 18,fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: customer.horsePowerUnits != 0,
          child: Container(
            width: phoneScreenSize.width,
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HorsePower Cost',
                  style: TextStyle(
                    fontSize: 18,fontWeight: FontWeight.w500
                  ),
                ),
                Text(
                  f.format(history.horsePowerPerUnitCostAtm),
                  style: const TextStyle(
                    fontSize: 18,fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Cost',
                style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500 ),
              ),
              Text(
                f.format(history.getTotalCost()),
                style:
                    const TextStyle(fontSize: 18,fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        Visibility(
          visible: history.paidAmount != 0,
          child: Container(
            width: phoneScreenSize.width,
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Left Over',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(
                  f.format((history.unpaidAmount())),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Debt',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,)
              ),
              Text(
                f.format((customer.debt - history.unpaidAmount())),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500,)
              ),
            ],
          ),
        ),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Due Date',
                style: TextStyle(
                  fontSize: 17,fontWeight: FontWeight.w500
                ),
              ),
              Text(
                paymentDueDate(history.date),
                style: const TextStyle(
                  fontSize: 17,fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
        const Text(
          '''
ElectricityPlus Office Ph No. 100101010,''',
          style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500
          ),
        ),
        Text(
          'Inspector: ${history.inspector}',
          style: const TextStyle(
            fontSize: 16,fontWeight: FontWeight.w500
          ),
        ),
        const Divider(),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meter Read Date',
                style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w500
                ),
              ),
              Text(
                'Unit Used',
                style: TextStyle(
                  fontSize: 17,fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
        for (var pastHistory in historyList)
          Container(
            width: phoneScreenSize.width,
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pastHistory.date.substring(0, 10),
                  style: const TextStyle(
                    fontSize: 17,fontWeight: FontWeight.w500
                  ),
                ),
                Text(
                  pastHistory.getUnitUsed().toString(),
                  style: const TextStyle(
                    fontSize: 17,fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        const Divider(),
      ],
    );
  }
}
