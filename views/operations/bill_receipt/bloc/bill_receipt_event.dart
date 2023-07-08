part of 'bill_receipt_bloc.dart';

abstract class BillReceiptEvent extends Equatable {
  const BillReceiptEvent();

  @override
  List<Object> get props => [];
}

class BillReceiptPaymentEvent extends BillReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  final String meterAllowance;
  const BillReceiptPaymentEvent({
    required this.customer,
    required this.history,
    required this.meterAllowance,
  });
}

class MeterAllowanceAcquisitionEvent extends BillReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const MeterAllowanceAcquisitionEvent({
    required this.customer,
    required this.history,
  });
}

class BillInitialise extends BillReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const BillInitialise({required this.customer, required this.history});
}

class BillFromHistorySearchInitialise extends BillInitialise {
  const BillFromHistorySearchInitialise({
    required CloudCustomer customer,
    required CloudCustomerHistory history,
  }) : super(customer: customer, history: history);
}

class BillFromFlaggedInitialise extends BillInitialise {
  const BillFromFlaggedInitialise({
    required CloudCustomer customer,
    required CloudCustomerHistory history,
  }) : super(customer: customer, history: history);
}

class BillQrInitialise extends BillReceiptEvent {
  final String qrCode;
  const BillQrInitialise({required this.qrCode});
}

class BillPrinterConnectEvent extends BillReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const BillPrinterConnectEvent(
      {required this.customer, required this.history});
}

class ReceiptPrinterConnectEvent extends BillReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  final CloudReceipt receipt;
  const ReceiptPrinterConnectEvent(
      {required this.customer, required this.history, required this.receipt});
}

class ReopenReceiptEvent extends BillReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const ReopenReceiptEvent({
    required this.customer,
    required this.history,
  });
}
