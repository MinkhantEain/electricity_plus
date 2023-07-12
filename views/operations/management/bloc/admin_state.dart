part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminStateAddCustomer extends AdminState {
  const AdminStateAddCustomer();
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
