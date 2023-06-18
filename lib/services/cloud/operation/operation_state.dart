import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/cloud_customer_history.dart';
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

class OperationStateSearchingCustomerReceipt extends OperationState {
  final Exception? exception;
  final Iterable<CloudCustomer> customerIterable;
  const OperationStateSearchingCustomerReceipt({
    required this.exception,
    required bool isLoading,
    required this.customerIterable,
  }) : super(isLoading: isLoading);
}

class OperationStateGeneratingReceipt extends OperationState {
  final String receiptDetails;
  final Exception? exception;
  const OperationStateGeneratingReceipt({
    required this.receiptDetails,
    required this.exception,
  }) : super(isLoading: false);
}

class OperationStateSettingPrice extends OperationState {
  final Exception? exception;
  final bool isChanged;
  final String currentPrice;
  final String currentServiceCharge;
  const OperationStateSettingPrice({
    required this.isChanged,
    required this.exception,
    required this.currentPrice,
    required this.currentServiceCharge,
  }) : super(isLoading: false);
}

class OperationStateFetchingCustomerReceiptHistory extends OperationState {
  final Iterable<CloudCustomerHistory> customerHistory;
  final CloudCustomer customer;
  const OperationStateFetchingCustomerReceiptHistory({
    required bool isLoading,
    required this.customerHistory,
    required this.customer,
  }) : super(isLoading: isLoading);
}

class OperationStateElectricLogSearch extends OperationState {
  final Exception? exception;
  final Iterable<CloudCustomer> customerIterable;
  const OperationStateElectricLogSearch(
      {required this.exception,
      required this.customerIterable,
      required bool isLoading})
      : super(isLoading: isLoading);
}

class OperationStateCreatingNewElectricLog extends OperationState {
  final CloudCustomer customer;
  final DocumentReference? newHistory;
  final Exception? exception;
  const OperationStateCreatingNewElectricLog({
    required this.customer,
    required this.newHistory,
    required bool isLoading,
    required this.exception,
  }) : super(isLoading: isLoading);
}

class OperationStateImageCommentFlag extends OperationState {
  final CloudCustomer customer;
  final DocumentReference newHistory;
  final Exception? exception;
  final num newReading;
  const OperationStateImageCommentFlag({
    required this.customer,
    required this.newHistory,
    required bool isLoading,
    required this.exception,
    required this.newReading,
  }) : super(isLoading: isLoading);
}
