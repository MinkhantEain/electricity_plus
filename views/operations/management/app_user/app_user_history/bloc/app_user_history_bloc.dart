import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/services/models/cloud_receipt_model.dart';
import 'package:electricity_plus/services/models/users.dart';
import 'package:equatable/equatable.dart';

part 'app_user_history_event.dart';
part 'app_user_history_state.dart';

class AppUserHistoryBloc
    extends Bloc<AppUserHistoryEvent, AppUserHistoryState> {
  AppUserHistoryBloc({required FirebaseCloudStorage provider})
      : super(const AppUserHistoryInitial(staffList: [])) {
    on<AppUserHistoryEventInitialise>((event, emit) async {
      emit(const AppUserHistoryStateLoading());
      final allStaff = await provider.getAllActiveStaff();
      emit(AppUserHistoryInitial(staffList: allStaff));
    });

    on<AppUserHistoryEventSelect>(
      (event, emit) {
        emit(const AppUserHistoryStateLoading());
        emit(
          AppUserHistoryStateSelected(
            staff: event.staff,
            staffList: event.staffList,
            radioState: event.staff.userType,
            history: const [],
            receipt: const [],
            meterStats: 0,
            receiptStats: 0,
          ),
        );
      },
    );

    on<AppUserHistoryEventChangeRadioState>(
      (event, emit) {
        emit(event.appUserHistoryState
            .changeRadioState(newRadioState: event.radioState));
      },
    );

    on<AppUserHistoryEventGetCashierHistory>(
      (event, emit) async {
        emit(const AppUserHistoryStateLoading());
        late final Iterable<CloudReceipt> result;
        if (event.staff.name == 'Daily Total') {
          result = await provider.getAllReceiptSpecificDate(
            date: event.date,
          );
        } else {
          result = await provider.getStaffReceiptSpecificDate(
            staff: event.staff,
            date: event.date,
          );
        }
        emit(AppUserHistoryStateSelected(
          staff: event.staff,
          staffList: event.staffList,
          history: const [],
          radioState: cashierType,
          receipt: result,
          receiptStats: result.isEmpty
              ? 0
              : result
                  .map((e) => e.paidAmount)
                  .reduce((value, element) => value + element),
          meterStats: 0,
        ));
      },
    );

    on<AppUserHistoryEventGetMeterReaderHistory>(
      (event, emit) async {
        emit(const AppUserHistoryStateLoading());
        late final Iterable<CloudCustomerHistory> result;
        if (event.staff.name == 'Daily Total') {
          result = await provider.getAllHistorySpecificDate(
            date: event.date,
          );
        } else {
          result = await provider.getStaffHistorySpecificDate(
            staff: event.staff,
            date: event.date,
          );
        }
        emit(AppUserHistoryStateSelected(
          staff: event.staff,
          receipt: const [],
          staffList: event.staffList,
          radioState: meterReaderType,
          history: result,
          meterStats: result.length,
          receiptStats: 0,
        ));
      },
    );

    on<AppUserHistoryEventStaffListView>(
      (event, emit) {
        emit(const AppUserHistoryStateLoading());
        emit(AppUserHistoryInitial(staffList: event.staffList));
      },
    );
  }
}
