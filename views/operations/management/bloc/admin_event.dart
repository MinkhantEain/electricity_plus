part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object?> get props => [];
}

class AdminEventAddCustomer extends AdminEvent {
  const AdminEventAddCustomer();
}

class AdminEventAppUser extends AdminEvent {
  const AdminEventAppUser();
}

class AdminEventAdminView extends AdminEvent {
  const AdminEventAdminView();
}

class AdminEventProduceExcel extends AdminEvent {
  const AdminEventProduceExcel();
}

class AdminEventInitialiseData extends AdminEvent {
  const AdminEventInitialiseData();
}

class AdminEventChooseTown extends AdminEvent {
  const AdminEventChooseTown();
}