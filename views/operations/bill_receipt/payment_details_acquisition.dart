import 'package:date_time_picker/date_time_picker.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/receipt_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev show log;

import 'package:intl/intl.dart';

class PaymentDetailsAcquisitionView extends StatefulWidget {
  const PaymentDetailsAcquisitionView({super.key});

  @override
  State<PaymentDetailsAcquisitionView> createState() =>
      _PaymentDetailsAcquisitionViewState();
}

class _PaymentDetailsAcquisitionViewState
    extends State<PaymentDetailsAcquisitionView> {
  late final TextEditingController amountPaidController;
  late final TextEditingController transactionIdController;
  late final TextEditingController bankController;
  String _paymentMethod = 'Cash';
  String _date = DateTime.now().toString();

  @override
  void initState() {
    amountPaidController = TextEditingController();
    transactionIdController = TextEditingController();
    bankController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    amountPaidController.dispose();
    transactionIdController.dispose();
    bankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceiptBloc, ReceiptState>(
      builder: (context, state) {
        state as ReceiptStatePaymentDetailsAcquitision;
        final f = NumberFormat('#,###,###,###,###,###', 'en_US');
        amountPaidController.text = f.format(state.customerHistory.cost);
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                Navigator.of(context)
                    .pop([state.customer, state.customerHistory]);
              },
            ),
            title: Text('Payment: ${f.format(state.customerHistory.unpaidAmount())}'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const Divider(
                  height: 10,
                ),
                const Text('Payment Method:'),
                RadioListTile(
                  value: 'Cash',
                  title: const Text('Cash'),
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value ?? '';
                    });
                    dev.log(value ?? '');
                  },
                ),
                RadioListTile(
                  value: 'Bank',
                  title: const Text('Bank'),
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value ?? '';
                    });
                    dev.log(value ?? '');
                  },
                ),
                const Divider(
                  height: 10,
                ),
                Visibility(
                  visible: _paymentMethod == 'Bank',
                  child: Row(
                    children: [
                      const Text('Bank Name: '),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: bankController,
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: _paymentMethod == 'Bank',
                  child: Row(
                    children: [
                      const Text('Transaction ID: '),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: transactionIdController,
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: _paymentMethod == 'Bank',
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: DateTimePicker(
                        initialDate: DateTime.parse(_date),
                        firstDate: DateTime.parse('0000-01-01'),
                        lastDate: DateTime.parse('9999-01-01'),
                        dateLabelText: 'Transaction Date',
                        onChanged: (value) {
                          dev.log(_date);
                          setState(() {
                            _date = value;
                          });
                          dev.log(_date);
                        },
                      ),
                    ),
                ),
                Row(
                  children: [
                    const Text('Amount Paid: '),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        enabled: false,
                        controller: amountPaidController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                    onPressed: () {
                      context.read<ReceiptBloc>().add(ReceiptEventMakePayment(
                            transactionDate: _date,
                            customer: state.customer,
                            customerHistory: state.customerHistory,
                            bank: bankController.text.trim(),
                            transactionId: transactionIdController.text.trim(),
                            paymentMethod: _paymentMethod.trim(),
                            paidAmount: amountPaidController.text.replaceAll(RegExp(r','), '').trim(),
                          ));
                    },
                    child: const Text('Submit')),
              ],
            ),
          ),
        );
      },
    );
  }
}
