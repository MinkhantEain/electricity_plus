part of 'app_user_bloc.dart';

abstract class AppUserState extends Equatable {
  const AppUserState();
  
  @override
  List<Object> get props => [];
}

class AppUserInitial extends AppUserState {
  const AppUserInitial();
}


class AppUserStateAddNewUser extends AppUserState {
  const AppUserStateAddNewUser();
}

class AppUserStateAppUser extends AppUserState {
  const AppUserStateAppUser();
}

class AppUserStateLoading extends AppUserState {
  const AppUserStateLoading();
}

class AppUserStateAppUserHisotry extends AppUserState {
  const AppUserStateAppUserHisotry();
}

class AppUserStateSuspendUser extends AppUserState {
  const AppUserStateSuspendUser();
}

class AppUserStateActivateUser extends AppUserState {
  const AppUserStateActivateUser();
}