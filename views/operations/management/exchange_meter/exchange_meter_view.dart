import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bill_view.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/bill_bloc.dart';
import 'package:electricity_plus/views/operations/management/exchange_meter/bloc/exchange_meter_bloc.dart';
import 'package:electricity_plus/views/operations/management/exchange_meter/exchange_meter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';

class ExchangeMeterView extends StatefulWidget {
  const ExchangeMeterView({super.key});

  @override
  State<ExchangeMeterView> createState() => _ExchangeMeterViewState();
}

class _ExchangeMeterViewState extends State<ExchangeMeterView> {
  final printerManager = PrinterManager.instance;
  late final TextEditingController exchangeReason;
  late final TextEditingController newUnit;
  late final TextEditingController unitUsed;
  late final TextEditingController calculationDetails;
  late final TextEditingController cost;
  late final TextEditingController newMeterId;
  late final TextEditingController initialMeterReading;
  late final TextEditingController newMeterCost;
  late final TextEditingController totalCost;
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    exchangeReason = TextEditingController();
    newUnit = TextEditingController();
    unitUsed = TextEditingController();
    calculationDetails = TextEditingController();
    cost = TextEditingController();
    newMeterId = TextEditingController();
    initialMeterReading = TextEditingController();
    newMeterCost = TextEditingController();
    totalCost = TextEditingController();
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    exchangeReason.dispose();
    newUnit.dispose();
    unitUsed.dispose();
    calculationDetails.dispose();
    cost.dispose();
    newMeterCost.dispose();
    newMeterId.dispose();
    initialMeterReading.dispose();
    totalCost.dispose();
    // _formKey.currentState!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExchangeMeterBloc, ExchangeMeterState>(
      listener: (context, state) async {
        if (state is ExchangeMeterStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is ExchangeMeterStateSubmitted) {
            await showFormSubmittedDialog(context).then((value) {
              context.read<OperationBloc>().add(
                    const OperationEventDefault(),
                  );
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) =>
                      BillBloc(provider: FirebaseCloudStorage())
                        ..add(BillEventInitialise(
                          customerHistory: state.history,
                          customer: state.customer,
                          historyList: const [],
                        )),
                  child: const BillView(),
                ),
              ));
            });
          }
        }
      },
      builder: (context, state) {
        if (state is ExchangeMeterStateInitial) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Meter Exchange'),
              leading: BackButton(
                onPressed: () => context
                    .read<OperationBloc>()
                    .add(const OperationEventDefault()),
              ),
            ),
            body: SingleChildScrollView(
                child: Column(
              children: [
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.always,
                  child: Column(
                    children: [
                      Text(
                        state.customer.bookId,
                        style: const TextStyle(
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        state.customer.name,
                        style: const TextStyle(
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        state.customer.address,
                        style: const TextStyle(
                            fontSize: 22, overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Temp ID',
                              style: TextStyle(
                                fontSize: 22,
                              ),
                            ),
                            Text(
                              getTempBookId(state.customer.bookId),
                              style: const TextStyle(
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Meter ID',
                              style: TextStyle(
                                fontSize: 22,
                              ),
                            ),
                            Text(
                              state.customer.meterId,
                              style: const TextStyle(
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                        child: TextFormField(
                          // autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            return (value == null || value.isEmpty)
                                ? 'Exchange reason cannot be empty'
                                : null;
                          },
                          textAlign: TextAlign.center,
                          controller: exchangeReason,
                          decoration: const InputDecoration(
                            labelText: 'Exchange Reason',
                          ),
                          style: const TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                            width: MediaQuery.of(context).size.width / 2,
                            child: TextFormField(
                              enabled: false,
                              // // autovalidateMode: AutovalidateMode.always,
                              initialValue: state.history.newUnit.toString(),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                return (value != null &&
                                        (value.contains('.') ||
                                            value.contains('-') ||
                                            !isIntInput(value)))
                                    ? 'Enter a valid unit'
                                    : null;
                              },
                              textAlign: TextAlign.end,
                              decoration: const InputDecoration(
                                labelText: 'Previous Unit',
                              ),
                              style: const TextStyle(
                                fontSize: 22,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                            width: MediaQuery.of(context).size.width / 2,
                            child: TextFormField(
                              // // autovalidateMode: AutovalidateMode.always,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                return (value != null &&
                                        (value.contains('.') ||
                                            value.contains('-') ||
                                            !isIntInput(value)))
                                    ? 'Enter a valid unit'
                                    : (num.parse(value!) >=
                                            state.history.newUnit)
                                        ? null
                                        : 'Must be greate than previous unit';
                              },
                              textAlign: TextAlign.end,
                              decoration: const InputDecoration(
                                labelText: 'Current Unit',
                              ),
                              controller: newUnit,
                              style: const TextStyle(
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: TextFormField(
                          // // autovalidateMode: AutovalidateMode.always,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return (value != null &&
                                    (value.contains('.') ||
                                        value.contains('-') ||
                                        !isIntInput(value)))
                                ? 'Enter a valid unit'
                                : null;
                          },
                          textAlign: TextAlign.end,
                          decoration: const InputDecoration(
                            labelText: 'Unit Used',
                          ),
                          controller: unitUsed,
                          style: const TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                        child: TextFormField(
                          // // autovalidateMode: AutovalidateMode.always,
                          minLines: 1,
                          maxLines: 5,
                          validator: (value) {
                            return (value == null || value.isEmpty)
                                ? 'Calculation details cannot be empty'
                                : null;
                          },
                          textAlign: TextAlign.start,
                          controller: calculationDetails,
                          decoration: const InputDecoration(
                            labelText: 'Calculation Details',
                          ),
                          style: const TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: TextFormField(
                          // // autovalidateMode: AutovalidateMode.always,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return (value != null &&
                                    (value.contains('.') ||
                                        value.contains('-') ||
                                        !isIntInput(value)))
                                ? 'Enter a valid cost'
                                : null;
                          },
                          textAlign: TextAlign.end,
                          decoration: const InputDecoration(
                            labelText: 'Cost',
                          ),
                          controller: cost,
                          style: const TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                        child: TextFormField(
                          // // autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            return (value == null || value.isEmpty)
                                ? 'New Meter ID cannot be empty'
                                : null;
                          },
                          textAlign: TextAlign.center,
                          controller: newMeterId,
                          decoration: const InputDecoration(
                            labelText: 'Meter ID (New)',
                          ),
                          style: const TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: TextFormField(
                          // // autovalidateMode: AutovalidateMode.always,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return (value != null &&
                                    (value.contains('.') ||
                                        value.contains('-') ||
                                        !isIntInput(value)))
                                ? 'Enter a valid unit'
                                : null;
                          },
                          textAlign: TextAlign.end,
                          decoration: const InputDecoration(
                            labelText: 'New Meter Initial Unit',
                          ),
                          controller: initialMeterReading,
                          style: const TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: TextFormField(
                          // // autovalidateMode: AutovalidateMode.always,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return (value != null &&
                                    (value.contains('.') ||
                                        value.contains('-') ||
                                        !isIntInput(value)))
                                ? 'Enter a valid new meter cost'
                                : null;
                          },
                          textAlign: TextAlign.end,
                          decoration: const InputDecoration(
                            labelText: 'New Meter Cost',
                          ),
                          controller: newMeterCost,
                          style: const TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: TextFormField(
                          // // autovalidateMode: AutovalidateMode.always,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return (value != null &&
                                    (value.contains('.') ||
                                        value.contains('-') ||
                                        !isIntInput(value)))
                                ? 'Enter a valid final cost'
                                : null;
                          },
                          textAlign: TextAlign.end,
                          decoration: const InputDecoration(
                            labelText: 'Total Cost',
                          ),
                          controller: totalCost,
                          style: const TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        context.read<ExchangeMeterBloc>().add(
                              ExchangeMeterEventSubmit(
                                calculationDetails:
                                    calculationDetails.text.trim(),
                                cost: cost.text.trim(),
                                exchangeReason: exchangeReason.text.trim(),
                                initialMeterReading:
                                    initialMeterReading.text.trim(),
                                newMeterCost: newMeterCost.text.trim(),
                                newMeterId: newMeterId.text.trim(),
                                newUnit: newUnit.text.trim(),
                                previousUnit: state.history.newUnit.toString(),
                                totalCost: totalCost.text.trim(),
                                unitUsed: unitUsed.text.trim(),
                              ),
                            );
                      } else {
                        await showFormErrorDialog(context);
                      }
                    },
                    child: const Text('Submit'))
              ],
            )),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
