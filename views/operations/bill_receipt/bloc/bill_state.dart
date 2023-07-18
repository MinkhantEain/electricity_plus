part of 'bill_bloc.dart';

abstract class BillState extends Equatable {
  const BillState();

  @override
  List<Object> get props => [];
}

class BillInitial extends BillState {
  @override
  List<Object> get props => [super.props];
  const BillInitial();
}

class BillInitialised extends BillInitial {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  final Iterable<CloudCustomerHistory> historyList;
  @override
  List<Object> get props => [
        super.props,
        customer,
        history,
        historyList,
      ];
  const BillInitialised({
    required this.customer,
    required this.history,
    required this.historyList,
  });
}

class BillStateLoading extends BillState {
  const BillStateLoading();
}

class BillStateReopenReceipt extends BillState {
  final CloudCustomer customer;
  final CloudCustomerHistory customerHistory;
  const BillStateReopenReceipt({
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

class BillStateNotFoundError extends BillState {
  const BillStateNotFoundError();
}

class BillStatePrinterNotConnected extends BillState {
  const BillStatePrinterNotConnected();
}

class BillStateMakePayment extends BillState {
  final CloudCustomer customer;
  final CloudCustomerHistory customerHistory;
  const BillStateMakePayment({
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

class BillStateInvalidMeterAllowance extends BillState {
  final String errorMessage;
  const BillStateInvalidMeterAllowance({
    required this.errorMessage,
  });

  @override
  List<Object> get props => [super.props, errorMessage];
}


class BillStateMeterAllowanceRecliberation extends BillState {
  final CloudCustomer customer;
  final CloudCustomerHistory customerHistory;
  final String meterAllowance;
  const BillStateMeterAllowanceRecliberation({
    required this.customer,
    required this.customerHistory,
    required this.meterAllowance,
  });

  @override
  List<Object> get props => [
        super.props,
        customer,
        meterAllowance,
        customerHistory,
      ];
}
