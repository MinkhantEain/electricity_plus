part of 'app_user_bloc.dart';

abstract class AppUserState extends Equatable {
  const AppUserState();
  
  @override
  List<Object> get props => [];
}

class AppUserInitial extends AppUserState {}


class AppUserStateAddNewUser extends AppUserState {
  const AppUserStateAddNewUser();
}

class AppUserStateAppUser extends AppUserState {
  const AppUserStateAppUser();
}

class AppUserStateLoading extends AppUserState {
  const AppUserStateLoading();
}

class AppUserStateUserMeterReadHisotry extends AppUserState {
  const AppUserStateUserMeterReadHisotry();
}

class AppUserStateUserPaymentCollectedHistory extends AppUserState {
  const AppUserStateUserPaymentCollectedHistory();
}

class AppUserStateSuspendUser extends AppUserState {
  const AppUserStateSuspendUser();
}

class AppUserStateActivateUser extends AppUserState {
  const AppUserStateActivateUser();
}