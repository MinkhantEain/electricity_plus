import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/dialogs/add_customer_dialogs.dart';
import 'package:electricity_plus/views/operations/add_customer/bloc/add_customer_bloc.dart';
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
    _meterMultiplierTextController.text = '1';
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
    return BlocListener<AddCustomerBloc, AddCustomerState>(
      listener: (context, state) async {
        if (state is AddCustomerStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is AddCustomerStateSubmitted) {
            await showCustomerDetailsSubmittedDialog(context,
                name: state.name, bookId: state.bookId);
          } else if (state is AddCustomerErrorStateInvalidInput) {
            await showCustomerInvalidInputDialog(context,
                field: state.field, input: state.input);
          } else if (state is AddCustomerErrorStateAlreadyExists) {
            await showCustomerAlreadyExistsDialog(context,
                bookId: state.bookId);
          } else if (state is AddCustomerErrorStateEmptyInput) {
            await showCustomerEmptyInputDialog(context);
          } else if (state is AddCustomerErrorState) {
            showCustomerAddUnexpectedErrorDialog(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Customer'),
          leading: BackButton(
            onPressed: () {
              context
                  .read<OperationBloc>()
                  .add(const OperationEventAdminView());
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
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
                  context.read<AddCustomerBloc>().add(AddCustomerEventSubmission(
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
      ),
    );
  }
}
