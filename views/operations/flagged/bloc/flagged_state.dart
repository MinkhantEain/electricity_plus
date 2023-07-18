part of 'flagged_bloc.dart';

typedef ContextualCallBack = void Function(
  BuildContext context,
  CloudCustomer customer,
);

abstract class FlaggedState extends Equatable {
  const FlaggedState();

  @override
  List<Object> get props => [];
}

class FlaggedInitial extends FlaggedState {
  const FlaggedInitial();
}

class FlaggedStateLoading extends FlaggedState {
  const FlaggedStateLoading();
}

class FlaggedStateBlackSelected extends FlaggedState {
  final CloudCustomer customer;
  final Iterable<CloudCustomerHistory> history;
  const FlaggedStateBlackSelected({
    required this.customer,
    required this.history,
  });
  @override
  List<Object> get props => [super.props, customer, history];
}

class FlaggedStateBillSelected extends FlaggedState {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  final Iterable<CloudCustomerHistory> historyList;
  const FlaggedStateBillSelected({
    required this.customer,
    required this.history,
    required this.historyList,
  });
  @override
  List<Object> get props => [super.props, customer, history];
}

class FlaggedStateRedSelected extends FlaggedState {
  final CloudCustomer customer;
  final CloudFlag flag;
  final Uint8List? image;
  const FlaggedStateRedSelected({
    required this.customer,
    required this.flag,
    required this.image,
  });
  @override
  // TODO: implement props
  List<Object> get props => [super.props, customer, flag];
}

class FlaggedStateUnreadCustomerSelected extends FlaggedState {
  final Iterable<CloudCustomer> customers;
  final CloudCustomer customer;
  final String previousReading;
  const FlaggedStateUnreadCustomerSelected({
    required this.customers,
    required this.customer,
    required this.previousReading,
  });
  @override
  List<Object> get props => [super.props, customer, previousReading, customers];
}

class FlaggedStatePageSelected extends FlaggedState {
  final Iterable<CloudCustomer> customers;
  final ContextualCallBack onTap;
  final String pageName;
  const FlaggedStatePageSelected({
    required this.customers,
    required this.onTap,
    required this.pageName,
  });
  @override
  // TODO: implement props
  List<Object> get props => [super.props, onTap, pageName];
}
