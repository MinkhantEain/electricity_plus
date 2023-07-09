import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_user_event.dart';
part 'app_user_state.dart';

class AppUserBloc extends Bloc<AppUserEvent, AppUserState> {
  AppUserBloc() : super(AppUserInitial()) {
    on<AppUserEventAppUser>((event, emit) => emit(const AppUserStateAppUser()));

    on<AppUserEventAddNewUser>(
        (event, emit) => emit(const AppUserStateAddNewUser()));

    on<AppUserEventUserMeterReadHisotry>(
        (event, emit) => emit(const AppUserStateUserMeterReadHisotry()));

    on<AppUserEventUserPaymentCollectedHistory>(
        (event, emit) => emit(const AppUserStateUserPaymentCollectedHistory()));

    on<AppUserEventSuspendUser>(
        (event, emit) => emit(const AppUserStateSuspendUser()));

    on<AppUserEventActivateUser>(
        (event, emit) => emit(const AppUserStateActivateUser()));
  }
}

// class AppUserEventAddNewUser extends AppUserEvent {
//   const AppUserEventAddNewUser();
// }

// class AppUserEventUserMeterReadHisotry extends AppUserEvent {
//   const AppUserEventUserMeterReadHisotry();
// }

// class AppUserEventUserPaymentCollectedHistory extends AppUserEvent {
//   const AppUserEventUserPaymentCollectedHistory();
// }

// class AppUserEventSuspendUser extends AppUserEvent {
//   const AppUserEventSuspendUser();
// }

// class AppUserEventActivateUser extends AppUserEvent {
//   const AppUserEventActivateUser();
// }