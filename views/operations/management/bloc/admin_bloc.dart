import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:electricity_plus/services/others/town.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as dev show log;

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc(FirebaseCloudStorage provider, String userType) : super(AdminInitial(userType: userType)) {
    on<AdminEventAdminView>(
      (event, emit) async => emit(AdminInitial(userType: userType)),
    );
    on<AdminEventChooseTown>(
      (event, emit) async {
        emit(const AdminStateLoading());
        late final Iterable<Town> cloudTowns;
        final localCount = await AppDocumentData.townCount();
        final dbCount = await provider.getTownCount();
        if (localCount == dbCount) {
          cloudTowns = await AppDocumentData.getTownList();
        } else {
          cloudTowns = await provider.getAllTown();
          await AppDocumentData.storeTownList(cloudTowns);
        }
        emit(AdminStateChooseTown(towns: cloudTowns));
      },
    );
    on<AdminEventAppUser>(
      (event, emit) {
        emit(const AdminStateLoading());
        emit(const AdminStateAppUser());
      },
    );
    on<AdminEventExchangeMeter>(
      (event, emit) {
        emit(const AdminStateLoading());
        emit(const AdminStateExchangeMeter());
      },
    );

    on<AdminEventEditCustomer>((event, emit) {
      emit(const AdminStateLoading());
      emit(const AdminStateEditCustomer());
    },);

    on<AdminEventMonthlyTotal>(
      (event, emit) async {
        emit(const AdminStateLoading());
        if (event.date.isEmpty) {
          emit(AdminStateMonthlyTotal(
            date: event.date,
            collectedAmount: 0,
            totalAllowedUnits: 0,
            totalCustomers: 0,
            totalExchangeMeters: 0,
            totalUnitUsed: 0,
            unpaidAmount: 0,
            unpaidCustomers: 0,
          ));
        } else {
          final history =
              await provider.getCustomerHistoryByMonth(givenDate: event.date);
          final exchangeHistory = await provider
              .getCustomerExchangeHistoryByMonth(givenDate: event.date);
          dev.log(history.toString());
          dev.log(exchangeHistory.toString());
          num collectedAmount = 0,
              totalAllowedUnits = 0,
              totalCustomers = 0,
              totalExchangeMeters = 0,
              totalUnitUsed = 0,
              unpaidAmount = 0,
              unpaidCustomers = 0;

          totalExchangeMeters = exchangeHistory.length;
          for (final element in history) {
            dev.log(element.toString());
            collectedAmount += element.paidAmount;
            totalAllowedUnits += element.meterAllowance;
            totalCustomers += 1;
            totalUnitUsed += element.getUnitUsed();
            unpaidAmount += element.unpaidAmount();
            unpaidCustomers += element.isPaid ? 1 : 0;
          }
          emit(AdminStateMonthlyTotal(
            date: event.date,
            collectedAmount: collectedAmount,
            totalAllowedUnits: totalAllowedUnits,
            totalCustomers: totalCustomers - totalExchangeMeters,
            totalExchangeMeters: totalExchangeMeters,
            totalUnitUsed: totalUnitUsed,
            unpaidAmount: unpaidAmount,
            unpaidCustomers: unpaidCustomers,
          ));
        }
      },
    );
  }
}
