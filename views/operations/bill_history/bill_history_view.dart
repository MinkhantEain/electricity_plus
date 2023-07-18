import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/views/operations/bill_history/bloc/bill_history_bloc.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bill_view.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/bill_bloc.dart';
import 'package:electricity_plus/views/operations/customer_search/bloc/customer_search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BillHistoryView extends StatefulWidget {
  const BillHistoryView({
    super.key,
  });

  @override
  State<BillHistoryView> createState() => _BillHistoryViewState();
}

class _BillHistoryViewState extends State<BillHistoryView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillHistoryBloc, BillHistoryState>(
      listener: (context, state) async {
        if (state is BillHistoryStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading');
        } else {
          LoadingScreen().hide();
          if (state is BillHistoryStateSelected) {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) =>
                      BillBloc(provider: FirebaseCloudStorage())
                        ..add(BillEventInitialise(
                            customer: state.customer,
                            customerHistory: state.history,
                            historyList: state.historyList)),
                  child: const BillView(),
                ),
              ),
            )
                .then((poppedCustomerAndHistory) async {
              final CloudCustomerHistory updatedHistory =
                  poppedCustomerAndHistory[1] as CloudCustomerHistory;
              var updateHistoryList = state.historyList
                  .where((element) => element.date != updatedHistory.date)
                  .toList();
              updateHistoryList.add(updatedHistory);
              return context
                  .read<BillHistoryBloc>()
                  .add(BillHistoryEventEmitState(
                      currentState: BillHistoryStateInitial(
                    customer: poppedCustomerAndHistory[0],
                    historyList: updateHistoryList,
                  )));
            });
          }
        }
      },
      builder: (context, state) {
        if (state is BillHistoryStateInitial) {
          final customerReceiptHisotryIterable = state.historyList;
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  context
                      .read<CustomerSearchBloc>()
                      .add(const CustomerSearchBillHistorySearchInitialise());
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
                    context.read<BillHistoryBloc>().add(BillHistoryEventSelect(
                          customer: state.customer,
                          history: customerReceiptHistory,
                          currentState: state,
                        ));
                  },
                  title: Text(
                    """
Date: ${customerReceiptHistory.date},
isPaid: ${customerReceiptHistory.isPaid},
cost: ${customerReceiptHistory.cost}, Paid: ${customerReceiptHistory.paidAmount}
                  """,
                    maxLines: 3,
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
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('fda'),
            ),
          );
        }
      },
    );
  }
}
