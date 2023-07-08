import 'package:electricity_plus/views/operations/flagged/bloc/flagged_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlackFlagCustomerView extends StatelessWidget {
  const BlackFlagCustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlaggedBloc, FlaggedState>(
      builder: (context, state) {
        if (state is FlaggedStateBlackSelected) {
          final historyList = state.history;
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  context.read<FlaggedBloc>().add(const FlaggedEventBlack());
                },
              ),
              title: Text(state.customer.name),
              actions: [Text('${state.customer.debt.toStringAsFixed(0)}ks')],
            ),
            body: ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final history = historyList.elementAt(index);
                return ListTile(
                  onTap: () {
                    context.read<FlaggedBloc>().add(FLaggedEventBillSelect(
                        history: history, customer: state.customer));
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        history.date.substring(0, 10),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        (history.cost - history.paidAmount).toStringAsFixed(0),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
