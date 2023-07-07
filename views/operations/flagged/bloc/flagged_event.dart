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

class FlaggedEventBlack extends FlaggedEvent {
  final CloudCustomer customer;
  const FlaggedEventBlack({
    required this.customer,
  });
}

class FlaggedEventBlackSelected extends FlaggedEvent {
  const FlaggedEventBlackSelected();
}