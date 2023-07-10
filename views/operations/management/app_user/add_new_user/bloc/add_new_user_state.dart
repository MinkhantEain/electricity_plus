part of 'add_new_user_bloc.dart';

abstract class AddNewUserState extends Equatable {
  const AddNewUserState();
  
  @override
  List<Object> get props => [];
}

class AddNewUserInitial extends AddNewUserState {
  const AddNewUserInitial(); 
}

class AddNewUserLoading extends AddNewUserState {
  const AddNewUserLoading();
}

class AddNewUserStateError extends AddNewUserState {
  const AddNewUserStateError();
}

class AddNewUserStateEmptyEmailError extends AddNewUserStateError {
  const AddNewUserStateEmptyEmailError();
}

class AddNewUserStateEmptyNameError extends AddNewUserStateError {
  const AddNewUserStateEmptyNameError();
}

class AddNewUserStateEmptyPasswordError extends AddNewUserStateError {
  const AddNewUserStateEmptyPasswordError();
}

class AddNewUserStateEmptyPasswordReEntryError extends AddNewUserStateError {
  const AddNewUserStateEmptyPasswordReEntryError();
}

class AddNewUserStateUndecidedTypeError extends AddNewUserStateError {
  const AddNewUserStateUndecidedTypeError();
}


class AddNewUserStatePasswordUnmatchError extends AddNewUserStateError {
  const AddNewUserStatePasswordUnmatchError();
}

class AddNewUserStateWeakPasswordError extends AddNewUserStateError {
  const AddNewUserStateWeakPasswordError();
}

class AddNewUserStateInvalidEmailError extends AddNewUserStateError {
  const AddNewUserStateInvalidEmailError();
}

class AddNewUserStateEmailAlreadyInUseError extends AddNewUserStateError {
  const AddNewUserStateEmailAlreadyInUseError();
}

class AddNewUserStateGenericAuthError extends AddNewUserStateError {
  const AddNewUserStateGenericAuthError();
}