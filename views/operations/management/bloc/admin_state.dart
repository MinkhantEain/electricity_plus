part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminStateLoading extends AdminState {
  const AdminStateLoading();
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

class AdminStateChooseTown extends AdminState {
  final Iterable<Town> towns;
  const AdminStateChooseTown({required this.towns});
}
