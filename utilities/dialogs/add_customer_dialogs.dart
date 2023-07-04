import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showCustomerDetailsSubmittedDialog(
  BuildContext context,
  {required String name,
  required String bookId,}
) {
  return showGenericDialog(
    context: context,
    title: "Customer Added",
    content: '$name, $bookId, has been added to the customer list.',
    optionsBuilder: () => {
      'OK' : null,
    },
  ).then((value) => context.read<OperationBloc>().add(const OperationEventDefault()));
}

Future<void> showCustomerInvalidInputDialog(
  BuildContext context,{required String field, required String input}
) {
  return showGenericDialog(
    context: context,
    title: "Invalid Input!",
    content: '$input is an invalid input for $field field',
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}

Future<void> showCustomerAlreadyExistsDialog(
  BuildContext context,{required String bookId}
) {
  return showGenericDialog(
    context: context,
    title: "Customer Already exists",
    content: 'Another customer with bookId:$bookId already exists in customer list.',
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}

Future<void> showCustomerEmptyInputDialog(
  BuildContext context
) {
  return showGenericDialog(
    context: context,
    title: "Empty Input Not Allowed",
    content: 'Please make sure to fill all the fields',
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}

Future<void> showCustomerAddUnexpectedErrorDialog(
  BuildContext context
) {
  return showGenericDialog(
    context: context,
    title: "Unexpected Error",
    content: 'An unexpected error has occured. Report to admin.',
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}