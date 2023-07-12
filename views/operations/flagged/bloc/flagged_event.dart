part of 'flagged_bloc.dart';

abstract class FlaggedEvent extends Equatable {
  const FlaggedEvent();

  @override
  List<Object> get props => [];
}

class FlaggedEventInitial extends FlaggedEvent {
  const FlaggedEventInitial();
}

class FlaggedEventRed extends FlaggedEvent {
  const FlaggedEventRed();
}

class FlaggedEventRedSelect extends FlaggedEvent {
  final CloudCustomer customer;
  const FlaggedEventRedSelect({
    required this.customer,
  });
  @override
  List<Object> get props => [super.props, customer];
}

class FlaggedEventBillSelect extends FlaggedEvent {
  final CloudCustomerHistory history;
  final CloudCustomer customer;
  const FlaggedEventBillSelect({
    required this.history,
    required this.customer,
  });
  @override
  List<Object> get props => [super.props, history, customer];
}

class FlaggedEventBlack extends FlaggedEvent {
  const FlaggedEventBlack();
}

class FlaggedEventBlackSelect extends FlaggedEvent {
  final CloudCustomer customer;
  const FlaggedEventBlackSelect({
    required this.customer,
  });
  @override
  List<Object> get props => [super.props,customer];
}

class FlaggedEventUnreadCustomers extends FlaggedEvent {
  final Iterable<CloudCustomer>? customers;
  const FlaggedEventUnreadCustomers({required this.customers});
}

class FlaggedEventUnreadCustomersSelect extends FlaggedEvent {
  final Iterable<CloudCustomer> customers;
  final CloudCustomer customer;
  const FlaggedEventUnreadCustomersSelect({
    required this.customers,
    required this.customer
  });

  @override
  List<Object> get props => [super.props, customer, customers];
}
