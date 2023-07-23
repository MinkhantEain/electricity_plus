import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/auth/auth_exception.dart';
import 'package:electricity_plus/services/auth/firebase_auth_provider.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:equatable/equatable.dart';

part 'add_new_user_event.dart';
part 'add_new_user_state.dart';

class AddNewUserBloc extends Bloc<AddNewUserEvent, AddNewUserState> {
  AddNewUserBloc() : super(const AddNewUserInitial()) {
    on<AddNewUserEvent>((event, emit) {
    
    });

    on<AddNewUserEventSubmit>(
      (event, emit) async {
        final currentUser = await AppDocumentData.getUserDetails();
        emit(const AddNewUserLoading());
        if (event.email.isEmpty) {
          emit(const AddNewUserStateEmptyEmailError());
          emit(const AddNewUserInitial());
        } else if (event.name.isEmpty) {
          emit(const AddNewUserStateEmptyNameError());
          emit(const AddNewUserInitial());
        } else if (event.password.isEmpty) {
          emit(const AddNewUserStateEmptyPasswordError());
          emit(const AddNewUserInitial());
        } else if (event.passwordReEntry.isEmpty) {
          emit(const AddNewUserStateEmptyPasswordReEntryError());
          emit(const AddNewUserInitial());
        } else if (event.userType == undecidedType) {
          emit(const AddNewUserStateUndecidedTypeError());
          emit(const AddNewUserInitial());
        } else if (event.password != event.passwordReEntry) {
          emit(const AddNewUserStatePasswordUnmatchError());
          emit(const AddNewUserInitial());
        } else {
          try {
            await FirebaseAuthProvider().createUser(
              email: event.email,
              name: event.name,
              password: event.password,
              userType: event.userType,
              passwordReEntry: event.passwordReEntry,
              isStaff: true,
            );
            await FirebaseAuthProvider().logIn(
              email: currentUser.email,
              password: currentUser.password,
            );
            emit(const AddNewUserInitial());
          } on WeakPasswordAuthException {
            emit(const AddNewUserStateWeakPasswordError());
            emit(const AddNewUserInitial());
          } on InvalidEmailAuthException {
            log('dfa');
            emit(const AddNewUserStateInvalidEmailError());
            emit(const AddNewUserInitial());
          } on EmailAlreadyInUseAuthException {
            emit(const AddNewUserStateEmailAlreadyInUseError());
            emit(const AddNewUserInitial());
          } on GenericAuthException {
            emit(const AddNewUserStateGenericAuthError());
            emit(const AddNewUserInitial());
          } on Exception catch (e) {
            log(e.toString());
          }
        }
      },
    );
  }
}
