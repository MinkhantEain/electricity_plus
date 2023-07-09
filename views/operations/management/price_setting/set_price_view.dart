import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/views/operations/management/price_setting/bloc/set_price_bloc.dart';
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
    return BlocConsumer<SetPriceBloc, SetPriceState>(
      listener: (context, state) async {
        if (state is SetPriceStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else if (state is SetPriceStateLoaded) {
          LoadingScreen().hide();
        } else if (state is SetPriceStateInvalidValueError) {
          LoadingScreen().hide();
          await showErrorDialog(context,
              'Invalid entry: One of the value you have entered is invalid');
        } else if (state is SetPriceStateNoPriceDocFoundError) {
          LoadingScreen().hide();
          await showErrorDialog(context,
              'Price document not found, price may not have been initialised, try initialise data')
              .then((value) => context.read<OperationBloc>().add(const OperationEventAdminView()));
        } else if (state is SetPriceStateInvalidPassowrd) {
          LoadingScreen().hide();
          await showErrorDialog(context, 'Unauthorized to set price');
        } else if (state is SetPriceStateGeneralError) {
          LoadingScreen().hide();
          await showErrorDialog(
              context, 'Unaccounted error: contact developer');
        }
      },
      builder: (context, state) {
        if (state is SetPriceStateLoaded) {
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
            body: SingleChildScrollView(
              child: Column(children: [
                //TODO: need to change in order to reduce reads, import all prices in one read
                Text('''
Current Price is ${state.price}
Current service charge is ${state.serviceCharge}
Current Horse Power/Unit is ${state.horsePowerPerUnitCost}
Current Road Light Cost is ${state.roadLightPrice}
'''),
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
                    context.read<SetPriceBloc>().add(SetPriceEventSubmit(
                          horsePowerPerUnitCost:
                              _horsePowerTextController.text.trim(),
                          roadLightPrice: _roadLightTextController.text.trim(),
                          newPrice: _priceTextController.text.trim(),
                          password: _tokenInputController.text,
                          serviceCharge: _serviceChargeController.text.trim(),
                        ));
                    _priceTextController.clear();
                    _tokenInputController.clear();
                    _serviceChargeController.clear();
                    _roadLightTextController.clear();
                    _horsePowerTextController.clear();
                  },
                  child: const Text("Enter"),
                ),
              ]),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(),
          );
        }
      },
    );
  }
}
