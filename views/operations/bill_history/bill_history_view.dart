import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/views/operations/bill_history/bloc/bill_history_bloc.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bill_view.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/bill_receipt_bloc.dart';
import 'package:electricity_plus/views/operations/customer_search/bloc/customer_search_bloc.dart';
import 'package:electricity_plus/views/operations/flagged/bloc/flagged_bloc.dart';
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
    return BlocBuilder<BillHistoryBloc, BillHistoryState>(
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
                          history: customerReceiptHistory,
                        ));
                  },
                  title: Text(
                    """
Date: ${customerReceiptHistory.date},
isVoided: ${customerReceiptHistory.isVoided},
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
        } else if (state is BillHistoryStateSelected) {
          return BlocProvider(
            create: (context) => BillReceiptBloc(FirebaseCloudStorage())
              ..add(BillFromHistorySearchInitialise(
                  customer: state.customer,
                  history: state.history,)),
            child: const BillView(),
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
