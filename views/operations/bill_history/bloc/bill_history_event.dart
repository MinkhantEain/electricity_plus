part of 'bill_history_bloc.dart';

abstract class BillHistoryEvent extends Equatable {
  const BillHistoryEvent();

  @override
  List<Object> get props => [];
}

class BillHistoryEventSelect extends BillHistoryEvent {
  final CloudCustomerHistory history;
  const BillHistoryEventSelect({
    required this.history,
  });
}

class BillHistoryEventReinitialise extends BillHistoryEvent {
  final CloudCustomer customer;
  const BillHistoryEventReinitialise({required this.customer});
}
