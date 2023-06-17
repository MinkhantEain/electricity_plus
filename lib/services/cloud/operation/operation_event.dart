import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/cloud_customer_history.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class OperationEvent {
  const OperationEvent();
}

class OperationEventDefault extends OperationEvent {
  const OperationEventDefault();
}

class OperationEventInitialise extends OperationEvent {
  const OperationEventInitialise();
}

class OperationEventCustomerReceiptSearch extends OperationEvent {
  final String userInput;
  final bool isSearching;
  const OperationEventCustomerReceiptSearch({
    required this.isSearching,
    required this.userInput,
  });
}

class OperationEventReceiptGeneration extends OperationEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory? customerHistory;
  const OperationEventReceiptGeneration({
    required this.customer,
    required this.customerHistory
  });
}

class OperationEventSetPriceIntention extends OperationEvent {
  const OperationEventSetPriceIntention();
}

class OperationEventSetPrice extends OperationEvent {
  final String price;
  final String tokenInput;
  final String serviceCharge;
  const OperationEventSetPrice({
    required this.price,
    required this.tokenInput,
    required this.serviceCharge,
  });
}

class OperationEventFetchCustomerReceiptHistory extends OperationEvent {
  final CloudCustomer customer;
  const OperationEventFetchCustomerReceiptHistory({
    required this.customer,
  });
}
