part of 'bill_bloc.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object> get props => [];
}

class BillEventInitialise extends BillEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory customerHistory;
  final Iterable<CloudCustomerHistory> historyList;
  const BillEventInitialise({
    required this.customerHistory,
    required this.customer,
    required this.historyList,
  });

  @override
  List<Object> get props => [
        super.props,
        customer,
        customerHistory,
        historyList,
      ];
}

class BillEventQrCodeInitialise extends BillEvent {
  final String qrCode;
  const BillEventQrCodeInitialise({required this.qrCode});

  @override
  List<Object> get props => [super.props, qrCode];
}

class BillEventReopenReceipt extends BillEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory customerHistory;

  const BillEventReopenReceipt({
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

class BillEventConnectPrinter extends BillEvent {
  final BillState resumeState;
  const BillEventConnectPrinter({required this.resumeState});
  @override
  List<Object> get props => [
        super.props,
        resumeState,
      ];
}

class BillEventMakePayment extends BillEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory customerHistory;
  const BillEventMakePayment({
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

class BillEventMeterAllowanceRecliberation extends BillEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory customerHistory;
  final Iterable<CloudCustomerHistory> historyList;
  final String meterAllowance;
  const BillEventMeterAllowanceRecliberation({
    required this.customer,
    required this.customerHistory,
    required this.meterAllowance,
    required this.historyList,
  });

  @override
  List<Object> get props => [
        super.props,
        customer,
        customerHistory,
        meterAllowance,
        historyList,
      ];
}
