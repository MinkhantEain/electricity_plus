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
}

class FLaggedEventBillSelect extends FlaggedEvent {
  final CloudCustomerHistory history;
  final CloudCustomer customer;
  const FLaggedEventBillSelect({
    required this.history,
    required this.customer,
  });
}

class FlaggedEventBlack extends FlaggedEvent {
  const FlaggedEventBlack();
}

class FlaggedEventBlackSelect extends FlaggedEvent {
  final CloudCustomer customer;
  const FlaggedEventBlackSelect({
    required this.customer,
  });
}
