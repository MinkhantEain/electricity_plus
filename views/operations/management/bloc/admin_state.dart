part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  final String userType;
  const AdminInitial({
    required this.userType
  });
  @override
  List<Object?> get props => [super.props, userType];
}

class AdminStateLoading extends AdminState {
  const AdminStateLoading();
}

class AdminStateEditCustomer extends AdminState {
  const AdminStateEditCustomer();
}

class AdminStateAddCustomer extends AdminState {
  const AdminStateAddCustomer();
}

class AdminStateExchangeMeter extends AdminState {
  const AdminStateExchangeMeter();
}

class AdminStateAppUser extends AdminState {
  const AdminStateAppUser();
}

class AdminStateProduceExcel extends AdminState {
  const AdminStateProduceExcel();
}

class AdminStateInitialiseData extends AdminState {
  const AdminStateInitialiseData();
}

class AdminStateMonthlyTotal extends AdminState {
  final String date;
  final num totalCustomers;
  final num totalExchangeMeters;
  final num totalUnitUsed;
  final num totalAllowedUnits;
  final num collectedAmount;
  final num unpaidAmount;
  final num unpaidCustomers;

  const AdminStateMonthlyTotal({
    required this.date,
    required this.collectedAmount,
    required this.totalAllowedUnits,
    required this.totalCustomers,
    required this.totalExchangeMeters,
    required this.totalUnitUsed,
    required this.unpaidAmount,
    required this.unpaidCustomers,
  });

  @override
  List<Object?> get props => [super.props,
  date,
  collectedAmount,
  totalAllowedUnits,
  totalCustomers,
  totalExchangeMeters,
  totalUnitUsed,
  unpaidAmount,
  unpaidCustomers,];
}

class AdminStateChooseTown extends AdminState {
  final Iterable<Town> towns;
  const AdminStateChooseTown({required this.towns});
}
