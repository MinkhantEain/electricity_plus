part of 'bill_history_bloc.dart';

abstract class BillHistoryEvent extends Equatable {
  const BillHistoryEvent();

  @override
  List<Object> get props => [];
}

class BillHistoryEventSelect extends BillHistoryEvent {
  final CloudCustomerHistory history;
  final CloudCustomer customer;
  final BillHistoryState currentState;
  const BillHistoryEventSelect({
    required this.history,
    required this.currentState,
    required this.customer,
  });

  @override
  List<Object> get props => [
        super.props,
        history,
        currentState,
        customer,
      ];
}

class BillHistoryEventEmitState extends BillHistoryEvent {
  final BillHistoryState currentState;
  const BillHistoryEventEmitState({required this.currentState});
  @override
  List<Object> get props => [super.props, currentState];
}
