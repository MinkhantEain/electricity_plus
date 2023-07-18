part of 'receipt_bloc.dart';

abstract class ReceiptState extends Equatable {
  const ReceiptState();

  @override
  List<Object> get props => [];
}

class ReceiptInitial extends ReceiptState {}

class ReceiptStatePaymentDetailsAcquitision extends ReceiptState {
  final CloudCustomer customer;
  final CloudCustomerHistory customerHistory;

  const ReceiptStatePaymentDetailsAcquitision({
    required this.customer,
    required this.customerHistory,
  });

  @override
  List<Object> get props => [
        super.props,
        customer,
        customerHistory,
      ];
}

class ReceiptStateLoading extends ReceiptState {
  const ReceiptStateLoading();
}

class ReceiptStateReceiptView extends ReceiptState {
  final CloudCustomer customer;
  final CloudCustomerHistory customerHistory;
  final CloudReceipt receipt;

  const ReceiptStateReceiptView({
    required this.customer,
    required this.customerHistory,
    required this.receipt,
  });

  @override
  List<Object> get props => [
        super.props,
        customer,
        customerHistory,
        receipt,
      ];
}

class ReceiptStatePrinterNotConnected extends ReceiptState {
  const ReceiptStatePrinterNotConnected();
}


class ReceiptStateReceiptRetrievalError extends ReceiptState {
  const ReceiptStateReceiptRetrievalError();
}

class ReceiptStateInvalidPaidAmountError extends ReceiptState {
  const ReceiptStateInvalidPaidAmountError();
}

class ReceiptStatePaidAmountMoreThanRequiredError extends ReceiptState {
  const ReceiptStatePaidAmountMoreThanRequiredError();
}

class ReceiptStateInvalidMeterAllowanceError extends ReceiptState {
  const ReceiptStateInvalidMeterAllowanceError();
}