import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bill_receipt_dialogs.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/bill_bloc.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/receipt_bloc.dart';
import 'package:electricity_plus/views/operations/bill_receipt/payment_details_acquisition.dart';
import 'package:electricity_plus/views/operations/bill_receipt/receipt_frame.dart';
import 'package:electricity_plus/views/operations/bill_receipt/receipt_page.dart';
import 'package:electricity_plus/views/operations/printer_select_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:intl/intl.dart';
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
                                      //TODO: implement the history for past 3 months
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
                                  await printBillReceipt80mm(
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
                        //TODO: implement payment method, implement access assigning
                        //TODO: must put hasPaymentCollectionRight to make payment
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
    var f = NumberFormat('#,###,###,###,###,###', 'en_US');
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
                    'assets/images/BillReceiptLogo.png',
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
                          fontSize: 22,fontWeight: FontWeight.w900
                        ),
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        Text(
          customer.name,
          style: const TextStyle(fontSize: 22,fontWeight: FontWeight.w900),
        ),
        Text(
          customer.address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 22,fontWeight: FontWeight.w900),
        ),
        Container(
          width: phoneScreenSize.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ငွေစာရင်းမှတ်',
                style: TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
                ),
              ),
              Text(
                customer.bookId,
                style: const TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
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
                'အသုံးပြုသည့်လ',
                style: TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
                ),
              ),
              Text(
                monthYearWordFormat(history.date),
                style: const TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
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
                'မီတာဖတ်သည့်နေ့',
                style: TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
                ),
              ),
              Text(
                dayMonthYearNumericFormat(history.date),
                style: const TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
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
                'မီတာအမှတ်',
                style: TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
                ),
              ),
              Text(
                customer.meterId,
                style: const TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
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
                'ယခင်လဖတ်ချက်',
                style: TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
                ),
              ),
              Text(
                f.format(history.previousUnit),
                style: const TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
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
                'ယခုလဖတ်ချက်',
                style: TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
                ),
              ),
              Text(
                f.format(history.newUnit),
                style: const TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
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
                  'မြှောက်ကိန်း',
                  style: TextStyle(
                    fontSize: 22,fontWeight: FontWeight.w900
                  ),
                ),
                Text(
                  history.meterMultiplier.toString(),
                  style: const TextStyle(
                    fontSize: 22,fontWeight: FontWeight.w900
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
                'သုံးစွဲယူနစ်',
                style: TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
                ),
              ),
              Text(
                f.format(history.getUnitUsed()),
                style: const TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
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
                  'ခွင့်ပြုယူနစ်',
                  style: TextStyle(
                    fontSize: 22,fontWeight: FontWeight.w900
                  ),
                ),
                Text(
                  f.format(history.meterAllowance),
                  style: const TextStyle(
                    fontSize: 22,fontWeight: FontWeight.w900
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
                  'မြင်းကောင်းရေ',
                  style: TextStyle(
                    fontSize: 22,fontWeight: FontWeight.w900
                  ),
                ),
                Text(
                  customer.horsePowerUnits.toString(),
                  style: const TextStyle(
                    fontSize: 22,fontWeight: FontWeight.w900
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
                'နှုန်း',
                style: TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
                ),
              ),
              Text(
                f.format(history.priceAtm),
                style: const TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
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
                'ကျသင့်ငွေ',
                style: TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
                ),
              ),
              Text(
                f.format(history.getCost()),
                style: const TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
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
                  'လမ်းမီးခ',
                  style: TextStyle(
                    fontSize: 22,fontWeight: FontWeight.w900
                  ),
                ),
                Text(
                  f.format(customer.hasRoadLightCost
                      ? history.roadLightPrice
                      : 0),
                  style: const TextStyle(
                    fontSize: 22,fontWeight: FontWeight.w900
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
                'မီတာဝန်ဆောင်ခ',
                style: TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
                ),
              ),
              Text(
                f.format(history.serviceChargeAtm),
                style: const TextStyle(
                  fontSize: 22,fontWeight: FontWeight.w900
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
                  'မြင်းကောင်ရေခ',
                  style: TextStyle(
                    fontSize: 22,fontWeight: FontWeight.w900
                  ),
                ),
                Text(
                  f.format(history.horsePowerPerUnitCostAtm),
                  style: const TextStyle(
                    fontSize: 22,fontWeight: FontWeight.w900
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
                'စုစုပေါင်းသင့်ငွေ',
                style: TextStyle(fontSize: 22,fontWeight: FontWeight.w900 ),
              ),
              Text(
                f.format(history.getTotalCost()),
                style:
                    const TextStyle(fontSize: 22,fontWeight: FontWeight.w900),
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
                  'ကျန်ငွေ',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                Text(
                  f.format((history.unpaidAmount())),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900),
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
                'ကြွေးကျန်',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,)
              ),
              Text(
                f.format((customer.debt - history.unpaidAmount())),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900,)
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
                'နောက်ဆုံးပေးဆောင်ရန်ရက်',
                style: TextStyle(
                  fontSize: 17,fontWeight: FontWeight.w900
                ),
              ),
              Text(
                paymentDueDate(history.date),
                style: const TextStyle(
                  fontSize: 17,fontWeight: FontWeight.w900
                ),
              ),
            ],
          ),
        ),
        const Text(
          '''
PTC Office Ph No. 059-51009,
09-426330134, 09-426330135''',
          style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w900
          ),
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
            fontSize: 16,fontWeight: FontWeight.w900
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
                'မီတာဖတ်ရက်',
                style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w900
                ),
              ),
              Text(
                'သုံးစွဲယူနစ်',
                style: TextStyle(
                  fontSize: 17,fontWeight: FontWeight.w900
                ),
              ),
            ],
          ),
        ),
        //TODO: complete this after making chages to cloudcustomer
        for (var pastHistory in historyList)
          Container(
            width: phoneScreenSize.width,
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pastHistory.date,
                  style: const TextStyle(
                    fontSize: 17,fontWeight: FontWeight.w900
                  ),
                ),
                Text(
                  pastHistory.getUnitUsed().toString(),
                  style: const TextStyle(
                    fontSize: 17,fontWeight: FontWeight.w900
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
