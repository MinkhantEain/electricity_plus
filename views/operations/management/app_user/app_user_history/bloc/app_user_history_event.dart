part of 'app_user_history_bloc.dart';

abstract class AppUserHistoryEvent extends Equatable {
  const AppUserHistoryEvent();

  @override
  List<Object> get props => [];
}

class AppUserHistoryEventInitialise extends AppUserHistoryEvent {
  const AppUserHistoryEventInitialise();
  @override
  List<Object> get props => [
        super.props,
      ];
}

class AppUserHistoryEventChangeRadioState extends AppUserHistoryEvent {
  final AppUserHistoryStateSelected appUserHistoryState;
  final String radioState;
  const AppUserHistoryEventChangeRadioState({
    required this.appUserHistoryState,
    required this.radioState,
  });
  @override
  List<Object> get props => [
        super.props,
        appUserHistoryState,
        radioState
      ];
}

class AppUserHistoryEventSelect extends AppUserHistoryEvent {
  final Iterable<Staff> staffList;
  final Staff staff;
  const AppUserHistoryEventSelect({
    required this.staff,
    required this.staffList,
  });
  @override
  List<Object> get props => [
        super.props,
        staff,
        staffList,
      ];
}

class AppUserHistoryEventGetCashierHistory extends AppUserHistoryEvent {
  final Staff staff;
  final String date;
  final Iterable<Staff> staffList;
  const AppUserHistoryEventGetCashierHistory({
    required this.staff,
    required this.date,
    required this.staffList,
  });
  @override
  List<Object> get props => [
        super.props,
        staff,
        date,
        staffList,
      ];
}

class AppUserHistoryEventGetMeterReaderHistory extends AppUserHistoryEvent {
  final Staff staff;
  final String date;
  final Iterable<Staff> staffList;
  const AppUserHistoryEventGetMeterReaderHistory({
    required this.staff,
    required this.date,
    required this.staffList,
  });
  @override
  List<Object> get props => [
        super.props,
        staff,
        date,
        staffList,
      ];
}

class AppUserHistoryEventStaffListView extends AppUserHistoryEvent {
  final Iterable<Staff> staffList;
  const AppUserHistoryEventStaffListView({
    required this.staffList,
  });
  @override
  List<Object> get props => [
        super.props,
        staffList,
      ];
}
