import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/models/users.dart';
import 'package:electricity_plus/views/operations/management/app_user/edit_user/bloc/edit_user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showSuspendUserConfirmationDialog(
    BuildContext context, Staff staff, Iterable<Staff> currentActiveStaff) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Suspend User',
    content: "Are you sure you want to suspend ${staff.name}?",
    optionsBuilder: () => {
      'No': false,
      'Yes': true,
    },
  )
      .then(
        (value) => value ?? false,
      )
      .then((value) => value
          ? context.read<EditUserBloc>().add(EditUserEventSuspendUser(
                toBeSuspendUser: staff,
                currentActiveStaff: currentActiveStaff,
              ))
          : context.read<EditUserBloc>().add(EditUserEventActiveUserView(
                currentActiveStaff: currentActiveStaff,
              )));
}

Future<void> showDeleteUserConfirmationDialog(
    BuildContext context, Staff staff, Iterable<Staff> currentSuspendedStaff) {
  return showGenericDialog<bool>(
    context: context,
    title: 'User Deletion',
    content: "Are you sure you want to delete ${staff.name}?",
    optionsBuilder: () => {
      'No': false,
      'Yes': true,
    },
  )
      .then(
        (value) => value ?? false,
      )
      .then((value) => value
          ? context.read<EditUserBloc>().add(EditUserEventDeleteSuspendedUser(
                toBeDeletedStaff: staff,
                currentSuspendedStaffs: currentSuspendedStaff,
              ))
          : null);
}

Future<void> showUserTypeOptionDialog(BuildContext context, Staff selectedStaff,
    Iterable<Staff> suspendedStaffs) async {
  return showGenericOptionDialog<String>(
    context: context,
    title: 'Choose Staff Type',
    optionsBuilder: () => {
      meterReaderType: meterReaderType,
      cashierType: cashierType,
      managerType: managerType,
      directorType: directorType,
    },
  ).then((value) {
    if (value == null) {
      context.read<EditUserBloc>().add(EditUserEventSuspendUserView(currentSuspendedStaffs: suspendedStaffs));
    } else  {
      context.read<EditUserBloc>().add(EditUserEventActivateSuspendedUser(currentSuspendedStaffs: suspendedStaffs,toBeActivatedStaff: selectedStaff, userType: value));
    }
  });
}


Future<void> showUserActivatedDialog(
    BuildContext context, Staff staff) {
  return showGenericDialog<bool>(
    context: context,
    title: 'User Activated',
    content: "${staff.name} has been activated",
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<void> showUserDeletedDialog(
    BuildContext context, Staff staff) {
  return showGenericDialog<bool>(
    context: context,
    title: 'User Deleted',
    content: "${staff.name} has been Deleted",
    optionsBuilder: () => {
      'OK': null,
    },
  );
}