
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SetPriceView extends StatefulWidget {
  const SetPriceView({super.key});

  @override
  State<SetPriceView> createState() => _SetPriceViewState();
}

class _SetPriceViewState extends State<SetPriceView> {
  late final TextEditingController _priceTextController;
  late final TextEditingController _serviceChargeController;
  late final TextEditingController _horsePowerTextController;
  late final TextEditingController _roadLightTextController;
  late final TextEditingController _tokenInputController;

  @override
  void initState() {
    _priceTextController = TextEditingController();
    _tokenInputController = TextEditingController();
    _horsePowerTextController = TextEditingController();
    _roadLightTextController = TextEditingController();
    _serviceChargeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _priceTextController.dispose();
    _tokenInputController.dispose();
    _serviceChargeController.dispose();
    _horsePowerTextController.dispose();
    _roadLightTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperationBloc, OperationState>(
      listener: (context, state) async {
        if (state is OperationStateSettingPrice) {
          if (state.exception is CouldNotSetPriceException) {
            await showErrorDialog(context,
                'Error: Could Not Set Price. Entered prices is an invalid value.');
          } else if (state.exception is UnAuthorizedPriceSetException) {
            await showErrorDialog(context, 'Error: Unauthorized to set price');
          } else if (state.exception is CouldNotSetServiceChargeException) {
            await showErrorDialog(context,
                'Error: Could Not Set Price. Entered prices is an invalid value.');
          }
        }
      },
      builder: (context, state) {
        state as OperationStateSettingPrice;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Price Setting"),
            leading: BackButton(
              onPressed: () {
                context
                    .read<OperationBloc>()
                    .add(const OperationEventAdminView());
              },
            ),
          ),
          body: Column(children: [
            Text('''Current Price is ${state.currentPrice}
Current service charge is ${state.currentServiceCharge}
Current Horse Power/Unit is ${state.currentHorsePowerPerUnitCost}
Current Road Light Cost is ${state.currentRoadLightPrice}'''),
            TextField(
              decoration:
                  const InputDecoration(hintText: "Enter the new price."),
              controller: _priceTextController,
              keyboardType: TextInputType.number,
            ),
            TextField(
              decoration: const InputDecoration(
                  hintText: "Enter the Service Charge Price."),
              controller: _serviceChargeController,
              keyboardType: TextInputType.number,
            ),
            TextField(
              decoration: const InputDecoration(
                  hintText: "Enter the horse power price."),
              controller: _horsePowerTextController,
              keyboardType: TextInputType.number,
            ),
            TextField(
              decoration: const InputDecoration(
                  hintText: "Enter the Road Light Price."),
              controller: _roadLightTextController,
              keyboardType: TextInputType.number,
            ),
            TextField(
              decoration: const InputDecoration(hintText: "Password"),
              controller: _tokenInputController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
            ElevatedButton(
              onPressed: () async {
                context.read<OperationBloc>().add(OperationEventSetPrice(
                      horsePowerPerUnitCost:
                          _horsePowerTextController.text.trim(),
                      roadLightPrice: _roadLightTextController.text.trim(),
                      price: _priceTextController.text.trim(),
                      tokenInput: _tokenInputController.text,
                      serviceCharge: _serviceChargeController.text.trim(),
                      isSettingPrice: true,
                    ));
                _priceTextController.clear();
                _tokenInputController.clear();
                _serviceChargeController.clear();
              },
              child: const Text("Enter"),
            ),
          ]),
        );
      },
    );
  }
}
