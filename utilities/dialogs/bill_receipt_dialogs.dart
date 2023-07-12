import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showNoHistoryDocumentErrorDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: "No such billing was made",
    content: 'Please check if the QR code is correct or the town selected is correct.',
    optionsBuilder: () => {
      'OK' : null,
    },
  ).then((value) => context.read<OperationBloc>().add(const OperationEventDefault()));
}

Future<void> showInvalidAllowanceErrorDialog(
  BuildContext context,
  {required String input}
) {
  return showGenericDialog(
    context: context,
    title: "Invalid Allowance input",
    content: '$input is not a valid allowance value',
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}

Future<void> showPaymentErrorDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: "Payment Error",
    content: 'Something went wrong during payment process. Ask Admin for help.',
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}

Future<void> showReceiptRetrievalErrorDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: "Receipt Retrieval Error",
    content: 'Something went wrong during payment process. Is the town correct? There is no receipt for imported or created bills, otherwise, Ask Admin for help.',
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}

Future<void> showPaymentRecordedSuccessfullyDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: "Payment Recorded",
    content: 'Payment Recorded Successfully.',
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}