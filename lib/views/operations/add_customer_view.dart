import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_exception.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCustomerView extends StatefulWidget {
  const AddCustomerView({super.key});

  @override
  State<AddCustomerView> createState() => _AddCustomerViewState();
}

class _AddCustomerViewState extends State<AddCustomerView> {
  late final TextEditingController _addressTextController;
  late final TextEditingController _bookIdTextController;
  late final TextEditingController _meterIdTextController;
  late final TextEditingController _nameTextController;
  late final TextEditingController _meterReadingTextController;
  late final TextEditingController _horsePowerUnitTextController;
  late final TextEditingController _meterMultiplierTextController;
  bool isChecked = false;

  @override
  void initState() {
    _addressTextController = TextEditingController();
    _bookIdTextController = TextEditingController();
    _meterReadingTextController = TextEditingController();
    _meterIdTextController = TextEditingController();
    _nameTextController = TextEditingController();
    _horsePowerUnitTextController = TextEditingController();
    _meterMultiplierTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _addressTextController.dispose();
    _bookIdTextController.dispose();
    _meterReadingTextController.dispose();
    _meterIdTextController.dispose();
    _nameTextController.dispose();
    _horsePowerUnitTextController.dispose();
    _meterMultiplierTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OperationBloc, OperationState>(
      listener: (context, state) async {
        if (state is OperationStateAddCustomer) {
          if (state.exception is EmptyTextInputException) {
            await showErrorDialog(context, 'Error: cannot have empty input');
          } else if (state.exception is InvalidMeterReadingException) {
            await showErrorDialog(context, 'Invalid Meter Reading input');
          } else if (state.exception is InvalidMeterMultiplierException) {
            await showErrorDialog(context, 'Invalid Meter Multiplier input');
          } else if (state.exception is InvalidHorsePowerUnitException) {
            await showErrorDialog(context, 'Invalid Horse Power input');
          } else if (state.exception is InvalidBookIdFormatException) {
            await showGenericDialog(
              context: context,
              title: "Error",
              content: 'Invalid Book ID input',
              optionsBuilder: () => {
                'OK': null,
              },
            );
          } else if (state.isSubmitted) {
            await showGenericDialog(
              context: context,
              title: "Success",
              content: 'New customer entry has been created.',
              optionsBuilder: () => {
                'OK': null,
              },
            ).then((value) => context
                .read<OperationBloc>()
                .add(const OperationEventDefault()));
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Customer'),
          leading: BackButton(
            onPressed: () {
              context.read<OperationBloc>().add(const OperationEventDefault());
            },
          ),
        ),
        body: Column(
          children: [
            Row(
              children: [
                const Text("Name: "),
                Expanded(
                    child: TextField(
                  controller: _nameTextController,
                )),
              ],
            ),
            Row(
              children: [
                const Text("Address: "),
                Expanded(
                    child: TextField(
                  controller: _addressTextController,
                )),
              ],
            ),
            Row(
              children: [
                const Text("MeterID: "),
                Expanded(
                    child: TextField(
                  controller: _meterIdTextController,
                )),
              ],
            ),
            Row(
              children: [
                const Text("BookID: "),
                Expanded(
                    child: TextField(
                  controller: _bookIdTextController,
                )),
              ],
            ),
            Row(
              children: [
                const Text("Current Meter Reading: "),
                Expanded(
                    child: TextField(
                  controller: _meterReadingTextController,
                  keyboardType: TextInputType.number,
                )),
              ],
            ),
            Row(
              children: [
                const Text("Horse Power Units: "),
                Expanded(
                    child: TextField(
                  controller: _horsePowerUnitTextController,
                  keyboardType: TextInputType.number,
                )),
              ],
            ),
            Row(
              children: [
                const Text("Meter Multiplier: "),
                Expanded(
                    child: TextField(
                  controller: _meterMultiplierTextController,
                  keyboardType: TextInputType.number,
                )),
              ],
            ),
            Row(
              children: [
                const Text("Include Road Light Cost:"),
                Checkbox(
                  value: isChecked,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                )
              ],
            ),
            ElevatedButton(
              onPressed: () {
                context.read<OperationBloc>().add(OperationEventAddCustomer(
                      address: _addressTextController.text.trim(),
                      meterId: _meterIdTextController.text.trim(),
                      name: _nameTextController.text.trim(),
                      bookId: _bookIdTextController.text.trim(),
                      meterReading: _meterReadingTextController.text.trim(),
                      horsePowerUnits:
                          _horsePowerUnitTextController.text.trim(),
                      meterMultiplier:
                          _meterMultiplierTextController.text.trim(),
                      hasRoadLight: isChecked,
                    ));
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
