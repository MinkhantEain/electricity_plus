import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:electricity_plus/enums/menu_action.dart';
import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_exception.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/home_page_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev show log;
import 'package:flutter_bloc/flutter_bloc.dart';

class ReceiptView extends StatefulWidget {
  const ReceiptView({super.key});

  @override
  State<ReceiptView> createState() => _ReceiptViewState();
}

class _ReceiptViewState extends State<ReceiptView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperationBloc, OperationState>(
      listener: (context, state) async {
        if (state is OperationStateGeneratingReceipt) {
          if (state.exception is CloudStorageException) {
            await showErrorDialog(
                context, "Error: unable to retrive customer history");
          } else if (state.exception is PrinterNotConnectedException) {
            await showErrorDialog(context, 'Printer Not Connected');
          }
        }
      },
      builder: (context, state) {
        state as OperationStateGeneratingReceipt;
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                context
                    .read<OperationBloc>()
                    .add(const OperationEventCustomerReceiptSearch(
                      isSearching: false,
                      userInput: '',
                    ));
              },
            ),
            title: const Text("Receipt"),
            actions: [
              PopupMenuButton<MenuAction>(
                onSelected: (value) async {
                  switch (value) {
                    case MenuAction.logout:
                      final shouldLogout = await showLogOutDialog(context);
                      if (shouldLogout) {
                        // ignore: use_build_context_synchronously
                        context.read<AuthBloc>().add(const AuthEventLogOut());
                      }
                      break;
                    case MenuAction.home:
                      final shouldGoHome = await showHomePageDialog(context);
                      if (shouldGoHome) {
                        // ignore: use_build_context_synchronously
                        context
                            .read<OperationBloc>()
                            .add(const OperationEventDefault());
                      }
                      break;
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: MenuAction.home,
                      child: Text("Home"),
                    ),
                    PopupMenuItem(
                      value: MenuAction.logout,
                      child: Text("Logout"),
                    ),
                  ];
                },
              )
            ],
          ),
          body: Column(
            children: [
              ElevatedButton(onPressed: () async {
                context.read<OperationBloc>().add(OperationEventPrintBill(printDetails: state.receiptDetails));
                dev.log((await BluetoothPrint.instance.isConnected).toString());
              }, child: const Text('Print')),
            ],
          ),
        );
      },
    );
  }
}
