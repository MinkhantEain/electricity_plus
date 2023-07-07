import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/dialogs/bill_receipt_dialogs.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:electricity_plus/views/operations/bill_history/bloc/bill_history_bloc.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/bill_receipt_bloc.dart';
import 'package:electricity_plus/views/operations/bill_receipt/meter_allowance_acquisition_page.dart';
import 'package:electricity_plus/views/operations/bill_receipt/receipt_page.dart';
import 'package:electricity_plus/views/operations/printer_select_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:developer' as dev show log;

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
    return BlocConsumer<BillReceiptBloc, BillReceiptState>(
      listener: (context, state) async {
        if (state is BillReceiptLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is BillReceiptErrorNotFound) {
            await showNoHistoryDocumentErrorDialog(context);
          } else if (state is InvalidMeterAllowanceInput) {
            await showInvalidAllowanceErrorDialog(context, input: state.input);
          } else if (state is PaymentError) {
            await showPaymentErrorDialog(context);
          } else if (state is ReceiptRetrievalUnsuccessful) {
            await showReceiptRetrievalErrorDialog(context);
          } else if (state is BillReceiptPaymentRecordedSuccessfully) {
            await showPaymentRecordedSuccessfullyDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is BillInitialised) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () async {
                  if (state is BillInitialisedFromLogHistory) {
                    context.read<BillHistoryBloc>().add(
                        BillHistoryEventReinitialise(customer: state.customer));
                  } else {
                    context
                        .read<OperationBloc>()
                        .add(const OperationEventDefault());
                  }
                },
              ),
              title: const Text("Bill"),
            ),
            body: Row(
              children: [
                SingleChildScrollView(
                    child: Column(
                  children: [
                    Bill(
                      customer: state.customer,
                      history: state.history,
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
                                      //TODO: Needs to correct the billing
                                      //TODO: implement the history for past 3 months
                                      child: Bill(
                                          customer: state.customer,
                                          history: state.history),
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
                                context.read<BillReceiptBloc>().add(
                                    BillPrinterConnectEvent(
                                        customer: state.customer,
                                        history: state.history));
                              }
                            },
                          ),
                        ),
                        //TODO: implement payment method, implement admin assigning
                        //TODO: must put hasPaymentCollectionRight to make payment
                        Visibility(
                            visible: !state.history.isPaid() &&
                                !state.history.isVoided,
                            child: ElevatedButton(
                              child: const Text('Make Payment'),
                              onPressed: () {
                                context.read<BillReceiptBloc>().add(
                                      MeterAllowanceAcquisitionEvent(
                                          customer: state.customer,
                                          history: state.history),
                                    );
                              },
                            )),
                        Visibility(
                            visible:
                                state.history.isPaid() && !state.history.isVoided,
                            child: ElevatedButton(
                              child: const Text('Receipt'),
                              onPressed: () {
                                context.read<BillReceiptBloc>().add(
                                      ReopenReceiptEvent(
                                          customer: state.customer,
                                          history: state.history),
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
        } else if (state is BillPrinterNotConnected) {
          return const PrinterSelectView();
        } else if (state is BillReceiptPaymentState) {
          return const ReceiptPage();
        } else if (state is MeterAllowanceAcquisitonState) {
          return const MeterAllowanceAcquisitionPage();
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
  const Bill({super.key, required this.customer, required this.history});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            const SizedBox(
              height: 22,
            ),
            SizedBox(
              width: 325,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/BillReceiptLogo.jpeg',
                    scale: 6,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Column(
                    children: [
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Phoe Thee Cho Co.Ltd',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              'ဓါတ်အားခတောင်းခံလွှာ',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Text(
          customer.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        Text(
          customer.address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ငွေစာရင်းမှတ်',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Text(
                customer.bookId,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'အသုံးပြုသည့်လ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Text(
                monthYearWordFormat(history.date),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'မီတာဖတ်သည့်နေ့',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Text(
                dayMonthYearNumericFormat(history.date),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'မီတာအမှတ်',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Text(
                customer.meterId,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ယခင်လဖတ်ချက်',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Text(
                history.previousUnit.toString(),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ယခုလဖတ်ချက်',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Text(
                history.newUnit.toString(),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ကွာခြားယူနစ်',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Text(
                (history.newUnit - history.previousUnit).toString(),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        // Container(
        //   width: 360,
        //   padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        //   child: const Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text(
        //         'ခွင့်ပြုယူနစ်',
        //         style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        //       ),
        //       Text(
        //         '0',
        //         style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        //       ),
        //     ],
        //   ),
        // ),
        Visibility(
          visible: history.meterMultiplier != 1,
          child: Container(
            width: 360,
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'မြှောက်ကိန်း',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                Text(
                  history.meterMultiplier.toString(),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        // Container(
        //   width: 360,
        //   padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       const Text(
        //         'ပေါင်းခြင်း',
        //         style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        //       ),
        //       Text(
        //         customer.adder.toString(),
        //         style:
        //             const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        //       ),
        //     ],
        //   ),
        // ),
        Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'သုံးစွဲယူနစ်',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Text(
                (history.newUnit - history.previousUnit).toString(),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Visibility(
          visible: customer.horsePowerUnits != 0,
          child: Container(
            width: 360,
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'မြင်းကောင်းရေ',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                Text(
                  customer.horsePowerUnits.toString(),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'နှုန်း',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Text(
                history.priceAtm.toString(),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ကျသင့်ငွေ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Text(
                history.basicElectricityPrice().toString(),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Visibility(
          visible: customer.hasRoadLightCost,
          child: Container(
            width: 360,
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'လမ်းမီးခ',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                Text(
                  customer.hasRoadLightCost
                      ? history.roadLightPrice.toString()
                      : '0',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'မီတာဝန်ဆောင်ခ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Text(
                history.serviceChargeAtm.toString(),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Visibility(
          visible: customer.horsePowerUnits != 0,
          child: Container(
            width: 360,
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'မြင်းကောင်ရေခ',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                Text(
                  history.horsePowerPerUnitCostAtm.toString(),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'စုစုပေါင်းသင့်ငွေ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Text(
                history.cost.toString(),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'နောက်ဆုံးပေးဆောင်ရန်ရက်',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              Text(
                paymentDueDate(history.date),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const Text(
          '059-51009,09-426330134, 09-426330135',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
//         const Text(
//           'အထူးမေတ္တာရပ်ခံချက်',
//           style: TextStyle(fontSize: 16,),
//         ),
//         const Text(
//           '''(၁) ဓာတ်အားခကိုယခုလ (၂၀)ရက်နေ့ နောက်ဆုံး
// ပေးသွင်းရန်''',
//           style: TextStyle(fontSize: 16,),
//         ),
//         const Text(
//           '''(၂) သတ်မှတ်ရက်ကျော်လွန်ပါက ဓာတ်အားယာယီ
// ဖြတ်တောက်ထားမည်ဖြစ်ပြီးဓာတ်အားခနှင့်ရက်
// လွန်ဒဏ်ကြေး (၂၀၀၀)ကျပ်ပေးသွင်းပြီးမှ ဓာတ်
// အားပြန်လည်သုံးစွဲခွင့်ရပါမည်။''',
//           style: TextStyle(fontSize: 16,),
//         ),
//         const Text(
//           '''(၃)မသမာနည်းဖြင့်လျှပ်စစ်ဓာတ်အားတရားမဝင်
// သုံးစွဲမှုများတွေ့ရှိပါကလျှပ်စစ်ဥပဒေနှင့်အညီသာ
// ဆောင်ရွက်သွားပါမည်။မီးပျက်တိုင်ကြားရန်ဖုန်း -
// 059-51009,09-426330134, 09-426330135''',
//           style: TextStyle(fontSize: 16,),
//         ),
//         const Divider(height: 10),
        Text(
          'Inspector: ${history.inspector}',
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
