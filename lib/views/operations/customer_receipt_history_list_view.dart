import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerReceiptHistoryList extends StatefulWidget {
  const CustomerReceiptHistoryList({super.key});

  @override
  State<CustomerReceiptHistoryList> createState() =>
      _CustomerReceiptHistoryListState();
}

class _CustomerReceiptHistoryListState
    extends State<CustomerReceiptHistoryList> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperationBloc, OperationState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        state as OperationStateFetchingCustomerReceiptHistory;
        final customerReceiptHisotryIterable = state.customerHistory;
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                context
                    .read<OperationBloc>()
                    .add(const OperationEventCustomerReceiptSearch(
                      isSearching: false,
                      userInput: '',
                    ));
              },
            ),
            title: const Text("Customer's History"),
          ),
          body: ListView.builder(
            itemCount: customerReceiptHisotryIterable.length,
            itemBuilder: (context, index) {
              final customerReceiptHistory =
                  customerReceiptHisotryIterable.elementAt(index);
              return ListTile(
                onTap: () {
                  context
                      .read<OperationBloc>()
                      .add(OperationEventReceiptGeneration(
                        customer: state.customer,
                        customerHistory: customerReceiptHistory,
                      ));
                },
                title: Text(
                  """
                  Date: ${customerReceiptHistory.date},
                  isVoided: ${customerReceiptHistory.isVoided},
                  """,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.zero),
                  side: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
