part of 'bill_receipt_bloc.dart';

abstract class BillReceiptEvent extends Equatable {
  const BillReceiptEvent();

  @override
  List<Object> get props => [];
}

class BillReceiptPaymentEvent extends BillReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  final Iterable<CloudCustomerHistory> recentHistory;
  final String meterAllowance;
  const BillReceiptPaymentEvent({
    required this.customer,
    required this.history,
    required this.meterAllowance,
    required this.recentHistory,
  });

  @override
  List<Object> get props => [
        super.props,
        customer,
        history,
        meterAllowance,
        recentHistory,
      ];
}

class MeterAllowanceAcquisitionEvent extends BillReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  final Iterable<CloudCustomerHistory> recentHistory;
  const MeterAllowanceAcquisitionEvent({
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

class BillInitialise extends BillReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const BillInitialise({required this.customer, required this.history});
  @override
  List<Object> get props => [
        super.props,
        customer,
        history,
      ];
}

class BillFromHistorySearchInitialise extends BillInitialise {
  const BillFromHistorySearchInitialise({
    required CloudCustomer customer,
    required CloudCustomerHistory history,
  }) : super(customer: customer, history: history);
  @override
  List<Object> get props => [
        super.props,
        customer,
        history,
      ];
}

class BillFromFlaggedInitialise extends BillInitialise {
  const BillFromFlaggedInitialise({
    required CloudCustomer customer,
    required CloudCustomerHistory history,
  }) : super(customer: customer, history: history);
  @override
  List<Object> get props => [
        super.props,
        customer,
        history,
      ];
}

class BillQrInitialise extends BillReceiptEvent {
  final String qrCode;
  const BillQrInitialise({required this.qrCode});
  @override
  List<Object> get props => [
        super.props,
        qrCode,
      ];
}

class BillPrinterConnectEvent extends BillReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  final Iterable<CloudCustomerHistory> recentHistory;
  const BillPrinterConnectEvent({
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

class ReceiptPrinterConnectEvent extends BillReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  final Iterable<CloudCustomerHistory> recentHistory;
  final CloudReceipt receipt;
  const ReceiptPrinterConnectEvent({
    required this.customer,
    required this.history,
    required this.receipt,
    required this.recentHistory,
  });
  @override
  List<Object> get props => [
        super.props,
        customer,
        history,
        receipt,
        recentHistory
      ];
}

class ReopenReceiptEvent extends BillReceiptEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  final Iterable<CloudCustomerHistory> recentHistory;
  const ReopenReceiptEvent({
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
