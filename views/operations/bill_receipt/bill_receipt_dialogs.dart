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
    content:
        'Please check if the QR code is correct or the town selected is correct.',
    optionsBuilder: () => {
      'OK': null,
    },
  ).then((value) =>
      context.read<OperationBloc>().add(const OperationEventDefault()));
}

Future<void> showInvalidAllowanceErrorDialog(BuildContext context, String errorMessage) {
  return showGenericDialog(
    context: context,
    title: "Invalid Meter Allowance input",
    content: errorMessage,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<void> showInvalidPaidAmountErrorDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: "Invalid Paid Amount input",
    content: 'Entered value is not a valid Paid Amount value',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<void> showMoreThanRequiredPaymentErrorDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: "Invalid Paid Amount input",
    content: 'The paid amount is more than required.',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<String> showAskForMeterAllowanceDialog(
  BuildContext context,
) {
  return showGenericInputEnquirerDialog<String>(
    context: context,
    title: "Enter meter allowance",
  ).then((value) => value ?? '');
}

Future<void> showPaymentErrorDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: "Payment Error",
    content: 'Something went wrong during payment process. Ask Admin for help.',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<void> showReceiptRetrievalErrorDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: "Receipt Retrieval Error",
    content: 'Receipt cannot be retrieved. Ask admin for assistance.',
    optionsBuilder: () => {
      'OK': null,
    },
  ).then((value) =>
      context.read<OperationBloc>().add(const OperationEventDefault()));
}

Future<void> showPaymentRecordedSuccessfullyDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: "Payment Recorded",
    content: 'Payment Recorded Successfully.',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
