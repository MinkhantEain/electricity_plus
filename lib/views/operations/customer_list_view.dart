import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:flutter/material.dart';

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
          title: Text(
            "Meter Number: ${customer.meterNumber}, BookID: ${customer.bookId}, Name: ${customer.bookId}",
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
