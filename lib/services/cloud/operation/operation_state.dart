import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class OperationState {
  final bool isLoading;
  final String? loadingText;
  const OperationState({
    required this.isLoading,
    this.loadingText,
  });
}

class OperationStateDefault extends OperationState {
  const OperationStateDefault() : super(isLoading: false);
}

class OperationStateUninitialised extends OperationState {
  const OperationStateUninitialised({required bool isLoading})
      : super(isLoading: isLoading);
}

class OperationStateSearchingCustomer extends OperationState {
  final Exception? exception;
  final Iterable<CloudCustomer> cloudCustomers;
  const OperationStateSearchingCustomer({
    required this.exception,
    required bool isLoading,
    required this.cloudCustomers,
  }) : super(isLoading: isLoading);
}

class OperationStateGeneratingReceipt extends OperationState {
  final String receiptDetails;
  const OperationStateGeneratingReceipt({
    required this.receiptDetails,
  }) : super(isLoading: false);
}

class OperationStateSettingPrice extends OperationState {
  final Exception? exception;
  final String? price;
  final bool isChanged;
  const OperationStateSettingPrice({
    required this.isChanged,
    required this.exception,
    required this.price,
  }) : super(isLoading: false);
}
