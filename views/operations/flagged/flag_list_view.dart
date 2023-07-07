import 'package:electricity_plus/views/operations/flagged/bloc/flagged_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FlagListView extends StatelessWidget {
  const FlagListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlaggedBloc, FlaggedState>(
      builder: (context, state) {
        if (state is FlaggedStatePageSelected) {
          final customers = state.customer;
          return Scaffold(
            appBar: AppBar(
              title: Text(state.pageName),
              leading: BackButton(
                onPressed: () {
                  context.read<FlaggedBloc>().add(const FlaggedEventInitial());
                },
              ),
            ),
            body: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers.elementAt(index);
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(customer.name),
                      Text(customer.bookId),
                    ],
                  ),
                  onTap: () {
                    state.onTap(context, customer);
                  },
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
