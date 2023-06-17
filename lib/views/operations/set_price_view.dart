import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/price_change_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev show log;

class SetPriceView extends StatefulWidget {
  const SetPriceView({super.key});

  @override
  State<SetPriceView> createState() => _SetPriceViewState();
}

class _SetPriceViewState extends State<SetPriceView> {
  late final TextEditingController _priceTextController;
  late final TextEditingController _serviceChargeController;
  late final TextEditingController _tokenInputController;

  @override
  void initState() {
    _priceTextController = TextEditingController();
    _tokenInputController = TextEditingController();
    _serviceChargeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _priceTextController.dispose();
    _tokenInputController.dispose();
    _serviceChargeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperationBloc, OperationState>(
      listener: (context, state) async {
        if (state is OperationStateSettingPrice) {
          dev.log(state.isChanged.toString());
          if (state.exception is CouldNotSetPriceException) {
            await showErrorDialog(context,
                'Error: Could Not Set Price. Entered prices is an invalid value.');
          } else if (state.exception is UnAuthorizedPriceSetException) {
            await showErrorDialog(context, 'Error: Unauthorized to set price');
          } else if (state.isChanged) {
            await showPriceChangeAlertDialog(context);
          } else if (!state.isChanged) {
            await showPriceUnhangeAlertDialog(context);
          }
          }
          
        },
      builder:(context, state) {
        state as OperationStateSettingPrice;
        return Scaffold(
        appBar: AppBar(
          title: const Text("Price Setting"),
        ),
        body: Column(children: [
          Text("Current Price is ${state.currentPrice}, Current service charge is ${state.currentServiceCharge}"),
          TextField(
            decoration: const InputDecoration(hintText: "Enter the new price."),
            controller: _priceTextController,
          ),
          TextField(
            decoration: const InputDecoration(hintText: "Enter the Service Charge Price."),
            controller: _serviceChargeController,
          ),
          TextField(
            decoration: const InputDecoration(hintText: "Password"),
            controller: _tokenInputController,
          ),
          ElevatedButton(
            onPressed: () async {
              context.read<OperationBloc>().add(OperationEventSetPrice(
                    price: _priceTextController.text,
                    tokenInput: _tokenInputController.text,
                    serviceCharge: _serviceChargeController.text
                  ));
            },
            child: const Text("Enter"),
          ),
          ElevatedButton(
              onPressed: () async {
                context.read<OperationBloc>().add(const OperationEventDefault());
              },
              child: const Text("Back"),),
        ]),
      );
      }, 
    );
  }
}
