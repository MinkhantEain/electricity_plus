part of 'app_user_history_bloc.dart';

abstract class AppUserHistoryState extends Equatable {
  const AppUserHistoryState();

  @override
  List<Object> get props => [];
}

class AppUserHistoryInitial extends AppUserHistoryState {
  final Iterable<Staff> staffList;
  const AppUserHistoryInitial({
    required this.staffList,
  });

  @override
  List<Object> get props => [super.props, staffList];
}

class AppUserHistoryStateLoading extends AppUserHistoryState {
  const AppUserHistoryStateLoading();
}

class AppUserHistoryStateSelected extends AppUserHistoryState {
  final Iterable<Staff> staffList;
  final Iterable<CloudCustomerHistory> history;
  final Iterable<CloudReceipt> receipt;
  final num meterStats;
  final num receiptStats;
  final Staff staff;
  final String radioState;
  const AppUserHistoryStateSelected({
    required this.staff,
    required this.staffList,
    required this.radioState,
    required this.history,
    required this.receipt,
    required this.meterStats,
    required this.receiptStats,
  });
  @override
  List<Object> get props => [
        super.props,
        staff,
        staffList,
        history,
        receipt,
        meterStats,
        receiptStats,
        radioState,
      ];

  AppUserHistoryStateSelected changeRadioState({required String newRadioState}) {
    return AppUserHistoryStateSelected(
      staff: staff,
      staffList: staffList,
      radioState: newRadioState,
      history: history,
      receipt: receipt,
      meterStats: meterStats,
      receiptStats: receiptStats,
    );
  }
}
