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
  final Iterable<CloudCustomerHistory> recentHistory;
  const BillPrinterNotConnected({
    required this.customer,
    required this.history,
    required this.recentHistory,
  });

  @override
  List<Object> get props => [
        super.props,
        customer,
        history,
        recentHistory,
      ];
}

class BillReceiptLoading extends BillReceiptState {
  const BillReceiptLoading();
}

class BillReceiptPaymentState extends BillReceiptState {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  final CloudReceipt receipt;
  final Iterable<CloudCustomerHistory> recentHistory;
  const BillReceiptPaymentState({
    required this.customer,
    required this.history,
    required this.receipt,
    required this.recentHistory,
  });

  @override
  List<Object> get props => [
        super.props,
        customer,
        recentHistory,
        history,
        receipt,
      ];
}

class BillReceiptPaymentRecordedSuccessfully extends BillReceiptState {
  const BillReceiptPaymentRecordedSuccessfully();
}

class MeterAllowanceAcquisitonState extends BillReceiptState {
  final num meterAllowance;
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  final Iterable<CloudCustomerHistory> recentHistory;
  const MeterAllowanceAcquisitonState({
    this.meterAllowance = 0,
    required this.customer,
    required this.history,
    required this.recentHistory,
  });

  @override
  List<Object> get props => [
        super.props,
        meterAllowance,
        customer,
        history,
      ];
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
  final Iterable<CloudCustomerHistory> recentHistory;
  const BillInitialised({
    required this.customer,
    required this.history,
    required this.recentHistory,
  });

  @override
  List<Object> get props => [
        super.props,
        customer,
        history,
        recentHistory,
      ];
}

class BillFromHistorySearchInitialised extends BillInitialised {
  const BillFromHistorySearchInitialised({
    required CloudCustomer customer,
    required CloudCustomerHistory history,
    required Iterable<CloudCustomerHistory> recentHistory,
  }) : super(
          customer: customer,
          history: history,
          recentHistory: recentHistory,
        );
  @override
  List<Object> get props => [
        super.props,
        customer,
        history,
        recentHistory,
      ];
}

class BillFromFlaggedInitialised extends BillInitialised {
  const BillFromFlaggedInitialised({
    required CloudCustomer customer,
    required CloudCustomerHistory history,
    required Iterable<CloudCustomerHistory> recentHistory,
  }) : super(
          customer: customer,
          history: history,
          recentHistory: recentHistory,
        );
  @override
  List<Object> get props => [
        super.props,
        customer,
        history,
        recentHistory,
      ];
}

class ReceiptInitialised extends BillReceiptState {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const ReceiptInitialised({
    required this.customer,
    required this.history,
  });
  @override
  List<Object> get props => [
        super.props,
        customer,
        history,
      ];
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
  @override
  List<Object> get props => [super.props, input];
}

class BillReceiptError extends BillReceiptState {
  const BillReceiptError();
}

class ReceiptPrinterNotConnected extends BillReceiptState {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  final Iterable<CloudCustomerHistory> recentHistory;
  const ReceiptPrinterNotConnected({
    required this.customer,
    required this.history,
    required this.recentHistory,
  });
  @override
  List<Object> get props => [
        super.props,
        customer,
        history,
        recentHistory,
      ];
}
