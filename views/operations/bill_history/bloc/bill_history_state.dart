part of 'bill_history_bloc.dart';

abstract class BillHistoryState extends Equatable {
  final Iterable<CloudCustomerHistory> historyList;
  const BillHistoryState({
    required this.historyList,
  });

  @override
  List<Object> get props => [historyList];
}

class BillHistoryStateInitial extends BillHistoryState {
  final CloudCustomer customer;
  const BillHistoryStateInitial({
    required Iterable<CloudCustomerHistory> historyList,
    required this.customer,
  }) : super(historyList: historyList);
  @override
  List<Object> get props => [super.props, customer];
}

class BillHistoryStateSelected extends BillHistoryState {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const BillHistoryStateSelected({
    required Iterable<CloudCustomerHistory> historyList,
    required this.customer,
    required this.history,
  }) : super(historyList: historyList);
  @override
  List<Object> get props => [super.props, customer];
}

class BillHistoryStateLoading extends BillHistoryState {
  const BillHistoryStateLoading({
    required Iterable<CloudCustomerHistory> historyList,
  }) : super(historyList: historyList);
}
