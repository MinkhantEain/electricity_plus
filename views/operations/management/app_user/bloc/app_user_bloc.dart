import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_user_event.dart';
part 'app_user_state.dart';

class AppUserBloc extends Bloc<AppUserEvent, AppUserState> {
  AppUserBloc() : super(const AppUserInitial()) {
    on<AppUserEventAppUser>((event, emit) => emit(const AppUserInitial()));

    on<AppUserEventAddNewUser>(
        (event, emit) => emit(const AppUserStateAddNewUser()));

    on<AppUserEventAppUserHistory>(
        (event, emit) => emit(const AppUserStateAppUserHisotry()));

    on<AppUserEventSuspendUser>(
        (event, emit) => emit(const AppUserStateSuspendUser()));

    on<AppUserEventActivateUser>(
        (event, emit) => emit(const AppUserStateActivateUser()));
  }
}