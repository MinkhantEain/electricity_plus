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

  @override
  void initState() {
    _addressTextController = TextEditingController();
    _bookIdTextController = TextEditingController();
    _meterReadingTextController = TextEditingController();
    _meterIdTextController = TextEditingController();
    _nameTextController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _addressTextController.dispose();
    _bookIdTextController.dispose();
    _meterReadingTextController.dispose();
    _meterIdTextController.dispose();
    _nameTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OperationBloc, OperationState>(
      listener: (context, state) async {
        if (state is OperationStateAddCustomer) {
          if (state.exception is EmptyTextInputException) {
            await showErrorDialog(context, 'Error: cannot have empty input');
          } else if (state.exception is UnableToParseException) {
            await showErrorDialog(context, 'Invalid Meter Reading input');
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
                const Text("Meter Reading: "),
                Expanded(
                    child: TextField(
                  controller: _meterReadingTextController,
                  keyboardType: TextInputType.number,
                )),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                context.read<OperationBloc>().add(OperationEventAddCustomer(
                      isSubmitted: true,
                      address: _addressTextController.text,
                      meterId: _meterIdTextController.text,
                      name: _nameTextController.text,
                      bookId: _bookIdTextController.text,
                      meterReading: _meterReadingTextController.text,
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
