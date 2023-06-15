import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/price_change_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SetPriceView extends StatefulWidget {
  const SetPriceView({super.key});

  @override
  State<SetPriceView> createState() => _SetPriceViewState();
}

class _SetPriceViewState extends State<SetPriceView> {
  late final TextEditingController _priceTextController;
  late final TextEditingController _tokenInputController;

  @override
  void initState() {
    _priceTextController = TextEditingController();
    _tokenInputController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _priceTextController.dispose();
    _tokenInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OperationBloc, OperationState>(
      listener: (context, state) async {
        if (state is OperationStateSettingPrice) {
          if (state.exception is CouldNotSetPriceException) {
            await showErrorDialog(context,
                'Error: Could Not Set Price. ${state.price} is an invalid value.');
          } else if (state.exception is UnAuthorizedPriceSetException) {
            await showErrorDialog(context, 'Error: Unauthorized to set price');
          } else if (state.isChanged) {
            await showPriceChangeAlertDialog(context, state.price!);
          }
          }
          
        },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Price Setting"),
        ),
        body: Column(children: [
          TextField(
            decoration: const InputDecoration(hintText: "Enter the new price."),
            controller: _priceTextController,
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
      ),
    );
  }
}
