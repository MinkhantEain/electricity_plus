import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_exception.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateElectricLogView extends StatefulWidget {
  const CreateElectricLogView({super.key});

  @override
  State<CreateElectricLogView> createState() => _CreateElectricLogViewState();
}

class _CreateElectricLogViewState extends State<CreateElectricLogView> {
  late final TextEditingController _newReadingTextController;

  @override
  void initState() {
    _newReadingTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _newReadingTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperationBloc, OperationState>(
      listener: (context, state) async {
        if (state is OperationStateCreatingNewElectricLog) {
          if (state.exception is UnableToParseException) {
            await showErrorDialog(context, 'The new reading cannot be parsed. Check your input.');
          } else if(state.exception is InvalidNewReadingException) {
            await showErrorDialog(context, 'The new reading cannot be lower than the previous reading, double check!');
          }
        }
      },
      builder: (context, state) {
        state as OperationStateCreatingNewElectricLog;
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                context
                    .read<OperationBloc>()
                    .add(const OperationEventElectricLogSearch(
                      isSearching: false,
                      userInput: '',
                    ));
              },
            ),
            title: const Text("New Electric Log"),
          ),
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("BookID: "),
                  Flexible(
                    fit: FlexFit.loose,
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: state.customer.bookId.toString()),
                      enabled: false,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("MeterID: "),
                  Flexible(
                    fit: FlexFit.loose,
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: state.customer.meterId.toString()),
                      enabled: false,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Name: "),
                  Flexible(
                    fit: FlexFit.loose,
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: state.customer.name.toString()),
                      enabled: false,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Address: "),
                  Flexible(
                    fit: FlexFit.loose,
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: state.customer.address.toString()),
                      enabled: false,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Previous Reading: "),
                  Flexible(
                    fit: FlexFit.loose,
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: state.customer.lastUnit.toString()),
                      enabled: false,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New Reading: "),
                  Flexible(
                    fit: FlexFit.loose,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'New Reading',
                      ),
                      controller: _newReadingTextController,
                      enabled: true,
                    ),
                  )
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_newReadingTextController.text.isEmpty) {
                    await showErrorDialog(
                        context, "New Reading cannot be empty!");
                  } else if (_newReadingTextController.text.contains('.') ||
                      _newReadingTextController.text.contains('-')) {
                    await showErrorDialog(
                        context, "having . and - are invalid input!");
                  } else {
                    context.read<OperationBloc>().add(
                          OperationEventCreateNewElectricLog(
                              customer: state.customer,
                              newReading: _newReadingTextController.text),
                        );
                        //TODO: need to ensure that when the customer is already logged
                        //for the month, the the previous unit must be obtained from the
                        //previous entry
                  }
                },
                child: const Text('Next'),
              ),
            ],
          ),
        );
      },
    );
  }
}
