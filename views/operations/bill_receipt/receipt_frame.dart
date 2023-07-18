import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bill_receipt_dialogs.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/receipt_bloc.dart';
import 'package:electricity_plus/views/operations/bill_receipt/payment_details_acquisition.dart';
import 'package:electricity_plus/views/operations/bill_receipt/receipt_page.dart';
import 'package:electricity_plus/views/operations/printer_select_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReceiptFrameView extends StatelessWidget {
  const ReceiptFrameView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReceiptBloc, ReceiptState>(
      listener: (context, state) async {
        if (state is ReceiptStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is ReceiptStatePrinterNotConnected) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const PrinterSelectView(),
            ));
          } else if (state is ReceiptStateReceiptRetrievalError) {
            Navigator.of(context).pop();
            await showReceiptRetrievalErrorDialog(context);
          } else if (state is ReceiptStateInvalidPaidAmountError) {
            await showInvalidPaidAmountErrorDialog(
              context,
            );
          } else if (state is ReceiptStatePaidAmountMoreThanRequiredError) {
            await showMoreThanRequiredPaymentErrorDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is ReceiptStatePaymentDetailsAcquitision) {
          return const PaymentDetailsAcquisitionView();
        } else if (state is ReceiptStateReceiptView) {
          return const ReceiptPage();
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
