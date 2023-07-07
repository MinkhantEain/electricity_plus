part of 'bill_receipt_bloc.dart';

abstract class BillReceiptState extends Equatable {
  const BillReceiptState();
  @override
  List<Object> get props => [];
}

class BillReceiptInitial extends BillReceiptState {
  const BillReceiptInitial();
}

class BillPrinterNotConnected extends BillReceiptState {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const BillPrinterNotConnected(
      {required this.customer, required this.history});
}

class BillReceiptLoading extends BillReceiptState {
  const BillReceiptLoading();
}

class BillReceiptPaymentState extends BillReceiptState {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  final CloudReceipt receipt;
  const BillReceiptPaymentState({
    required this.customer,
    required this.history,
    required this.receipt,
  });
}

class BillReceiptPaymentRecordedSuccessfully extends BillReceiptState {
  const BillReceiptPaymentRecordedSuccessfully();
}

class MeterAllowanceAcquisitonState extends BillReceiptState {
  final num meterAllowance;
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const MeterAllowanceAcquisitonState({
    this.meterAllowance = 0,
    required this.customer,
    required this.history,
  });
}

// class PrintReceiptState extends BillReceiptPaymentState {
//   const PrintReceiptState({
//     required CloudCustomer customer,
//     required CloudCustomerHistory history,
//   }) : super(customer: customer, history: history);
// }

class BillInitialised extends BillReceiptState {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const BillInitialised({required this.customer, required this.history});
}

class BillInitialisedFromLogHistory extends BillInitialised {
  const BillInitialisedFromLogHistory({required CloudCustomer customer, required CloudCustomerHistory history})
  : super(customer: customer, history: history);
}

class ReceiptInitialised extends BillReceiptState {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const ReceiptInitialised({required this.customer, required this.history});
}

class BillReceiptErrorNotFound extends BillReceiptError {
  const BillReceiptErrorNotFound();
}

class ReceiptRetrievalUnsuccessful extends BillReceiptError {
  const ReceiptRetrievalUnsuccessful();
}

class PaymentError extends BillReceiptError {
  const PaymentError();
}

class InvalidMeterAllowanceInput extends BillReceiptError {
  final String input;
  const InvalidMeterAllowanceInput({required this.input});
}

class BillReceiptError extends BillReceiptState {
  const BillReceiptError();
}

class ReceiptPrinterNotConnected extends BillReceiptState {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const ReceiptPrinterNotConnected(
      {required this.customer, required this.history});
}

