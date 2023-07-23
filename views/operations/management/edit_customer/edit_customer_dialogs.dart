import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:flutter/material.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showEditCustomerSuccessDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Form Submitted',
    content: "Customer details has been changed.",
    optionsBuilder: () => {
      'OK': null,
    },
  ).then((value) =>
      context.read<OperationBloc>().add(const OperationEventDefault()));
}
