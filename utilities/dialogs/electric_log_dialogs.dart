import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/views/operations/read_meter/bloc/read_meter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showEmptyInputErrorDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: "Empty Input",
    content: 'Cannot have empty input',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<void> showInvalidInputDialog(BuildContext context, String input) {
  return showGenericDialog(
    context: context,
    title: "Invalid Input",
    content: '$input is invalid.',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<void> showLogSubmittedDialog(
  BuildContext context, {required CloudCustomer customer, required CloudCustomerHistory history}
) {
  return showGenericDialog(
    context: context,
    title: "Log Submitted!",
    content: 'The electric log has been successfully submitted',
    optionsBuilder: () => {
      'OK': null,
    },
  ).then((value) async {
    context.read<OperationBloc>().add(OperationEventBillGeneration(
        customer: customer, customerHistory: history));
    await BlocProvider.of<ReadMeterBloc>(context).close();
  });
}

Future<void> showFlagReportSubmittedDialog(
  BuildContext context
) {
  return showGenericDialog(
    context: context,
    title: "Flag Report Submitted!",
    content: 'The Flag Report has been successfully submitted',
    optionsBuilder: () => {
      'OK': null,
    },
  ).then((value) async {
    context.read<OperationBloc>().add(const OperationEventDefault());
    await BlocProvider.of<ReadMeterBloc>(context).close();
  });
}

Future<void> showUnableToUploadDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: "Unable to Upload",
    content: 'Something went wrong during uploading, ask admin for assistance',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<void> showUnableToUpdateDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: "Unable To Update",
    content: 'Something went wrong during updating, ask admin for assistance',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<void> showGenericLogErrorDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: "Error",
    content: 'Something unexpected happened, ask admin for assistance',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
