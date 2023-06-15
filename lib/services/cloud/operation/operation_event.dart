import 'package:electricity_plus/services/cloud/cloud_customer.dart';
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

class OperationEventCustomerSearch extends OperationEvent {
  final String? userInput;
  final bool isSearching;
  const OperationEventCustomerSearch(
      {required this.isSearching, this.userInput});
}

class OperationEventReceiptGeneration extends OperationEvent {
  final CloudCustomer? customer;
  const OperationEventReceiptGeneration({required this.customer});
}

class OperationEventSetPriceIntention extends OperationEvent {
  const OperationEventSetPriceIntention();
}

class OperationEventSetPrice extends OperationEvent {
  final String price;
  final String tokenInput;
  const OperationEventSetPrice({
    required this.price,
    required this.tokenInput,
  });
}
