import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef CustomerCallBack = void Function(CloudCustomer customer);

class CustomerListView extends StatelessWidget {
  final Iterable<CloudCustomer> customers;
  final CustomerCallBack onTap;

  const CustomerListView({
    super.key,
    required this.customers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(customer);
          },
          trailing: IconButton(
            onPressed: () {
              context
                  .read<OperationBloc>()
                  .add(OperationEventFetchCustomerHistory(
                    customer: customer,
                  ));
            },
            icon: const Icon(Icons.receipt_long_rounded),
            iconSize: 30,
          ),
          title: Text(
            """
            Meter Number: ${customer.meterId},
            BookID: ${customer.bookId},
            Name: ${customer.name},
            Address: ${customer.address}
            """,
            maxLines: 4,
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
    );
  }
}
