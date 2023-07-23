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

class AdminEventExchangeMeter extends AdminEvent {
  const AdminEventExchangeMeter();
}

class AdminEventMonthlyTotal extends AdminEvent {
  final String date;
  const AdminEventMonthlyTotal({
    this.date = '',
  });
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

class AdminEventEditCustomer extends AdminEvent {
  const AdminEventEditCustomer();
}