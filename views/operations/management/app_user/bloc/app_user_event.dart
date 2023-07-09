part of 'app_user_bloc.dart';

abstract class AppUserEvent extends Equatable {
  const AppUserEvent();

  @override
  List<Object> get props => [];
}

class AppUserEventAddNewUser extends AppUserEvent {
  const AppUserEventAddNewUser();
}

class AppUserEventAppUser extends AppUserEvent {
  const AppUserEventAppUser();
}

class AppUserEventUserMeterReadHisotry extends AppUserEvent {
  const AppUserEventUserMeterReadHisotry();
}

class AppUserEventUserPaymentCollectedHistory extends AppUserEvent {
  const AppUserEventUserPaymentCollectedHistory();
}

class AppUserEventSuspendUser extends AppUserEvent {
  const AppUserEventSuspendUser();
}

class AppUserEventActivateUser extends AppUserEvent {
  const AppUserEventActivateUser();
}