import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showUnauthorisedUserDialog(BuildContext context) async {
   return showGenericDialog(
    context: context,
    title: 'UnauthorisedUser',
    content: "${FirebaseAuth.instance.currentUser!.uid} is unauthorised",
    optionsBuilder: () => {
      'OK' : null,
    },
  ).then((_) => context.read<OperationBloc>().add(const OperationEventDefault()));
}