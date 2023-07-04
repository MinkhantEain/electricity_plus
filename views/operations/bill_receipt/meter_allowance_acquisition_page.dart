import 'package:electricity_plus/views/operations/bill_receipt/bloc/bill_receipt_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MeterAllowanceAcquisitionPage extends StatefulWidget {
  const MeterAllowanceAcquisitionPage({super.key});

  @override
  State<MeterAllowanceAcquisitionPage> createState() =>
      _MeterAllowanceAcquisitionPageState();
}

class _MeterAllowanceAcquisitionPageState
    extends State<MeterAllowanceAcquisitionPage> {
  late final TextEditingController meterAllowanceController;

  @override
  void initState() {
    meterAllowanceController = TextEditingController();
    meterAllowanceController.text = '0';
    super.initState();
  }

  @override
  void dispose() {
    meterAllowanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillReceiptBloc, BillReceiptState>(
      builder: (context, state) {
        if (state is MeterAllowanceAcquisitonState) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  context.read<BillReceiptBloc>().add(
                        BillInitialise(
                          customer: state.customer,
                          history: state.history,
                        ),
                      );
                },
              ),
              title: const Text('Payment'),
            ),
            body: Column(
              children: [
                TextField(
                  controller: meterAllowanceController,
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                    onPressed: () {
                      //TODO: make payment
                      context.read<BillReceiptBloc>().add(
                          BillReceiptPaymentEvent(
                              customer: state.customer,
                              history: state.history,
                              meterAllowance: meterAllowanceController.text));
                    },
                    child: const Text('Submit')),
              ],
            ),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
