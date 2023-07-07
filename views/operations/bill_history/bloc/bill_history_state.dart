part of 'bill_history_bloc.dart';

abstract class BillHistoryState extends Equatable {
  const BillHistoryState();

  @override
  List<Object> get props => [];
}

class BillHistoryStateInitial extends BillHistoryState {
  final Iterable<CloudCustomerHistory> historyList;
  final CloudCustomer customer;
  const BillHistoryStateInitial({
    required this.historyList,
    required this.customer,
  });
}



class BillHistoryStateSelected extends BillHistoryState {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const BillHistoryStateSelected({
    required this.customer,
    required this.history,
  });
}

class BillHistoryStateLoading extends BillHistoryState {
  const BillHistoryStateLoading();
}
