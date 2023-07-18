part of 'receipt_bloc.dart';

abstract class ReceiptEvent extends Equatable {
  const ReceiptEvent();

  @override
  List<Object> get props => [];
}

class ReceiptEventReopenReceipt extends ReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory customerHistory;
  const ReceiptEventReopenReceipt({
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

class ReceiptEventConnectPrinter extends ReceiptEvent {
  final ReceiptState resumeState;
  const ReceiptEventConnectPrinter({
    required this.resumeState,
  });
  @override
  List<Object> get props => [
        super.props,
        resumeState,
      ];
}

class ReceiptEventMakePayment extends ReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory customerHistory;
  final String bank;
  final String transactionId;
  final String transactionDate;
  final String paymentMethod;
  final String paidAmount;
  const ReceiptEventMakePayment(
      {required this.customer,
      required this.customerHistory,
      required this.transactionDate,
      required this.bank,
      required this.paidAmount,
      required this.paymentMethod,
      required this.transactionId});

  @override
  List<Object> get props => [
        super.props,
        customer,
        customerHistory,
        bank,
        paidAmount,
        paymentMethod,
        transactionDate,
        transactionId,
      ];
}

class ReceiptEventPaymentDetailAcquisition extends ReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory customerHistory;
  const ReceiptEventPaymentDetailAcquisition({
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