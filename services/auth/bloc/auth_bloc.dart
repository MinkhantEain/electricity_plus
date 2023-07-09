import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/models/users.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electricity_plus/services/auth/auth_provider.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialised(isLoading: true, townList: [])) {
    on<AuthEventShouldRegister>(
      (event, emit) async {
        var town = await AppDocumentData.getTownName();
        if (town == 'Town Not Chosen') {
          town = (await FirebaseCloudStorage().getAllTown()).first.townName;
        }
        emit(AuthStateRegistering(
            exception: null,
            isLoading: false,
            townList: event.townList,
            town: town));
      },
    );

    //send email verification
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      },
    );

    //forgot password
    on<AuthEventForgotPassword>(
      (event, emit) async {
        emit(AuthStateForgotPassword(
            exception: null,
            hasSentEmail: false,
            isLoading: false,
            townList: event.townList));
        final email = event.email;
        if (email == null) {
          return; //user just want to go to forgot password screen
        }

        //user wants to actually send a forgot-password email
        emit(AuthStateForgotPassword(
            exception: null,
            hasSentEmail: false,
            isLoading: true,
            townList: event.townList));

        bool didSendEmail;
        Exception? exception;
        try {
          await provider.sendPasswordReset(email: email);
          didSendEmail = true;
          exception = null;
        } on Exception catch (e) {
          didSendEmail = false;
          exception = e;
        }

        emit(AuthStateForgotPassword(
            exception: exception,
            hasSentEmail: didSendEmail,
            isLoading: false,
            townList: event.townList));
      },
    );

    on<AuthEventRegister>(
      (event, emit) async {
        emit(AuthStateRegistering(
            exception: null,
            isLoading: true,
            townList: event.townList,
            town: event.town));
        final email = event.email;
        final name = event.name;
        final password = event.password;
        final passwordReEntry = event.passwordReEntry;
        try {
          await provider.createUser(
            name: name,
            email: email,
            password: password,
            passwordReEntry: passwordReEntry,
          );
          await provider.sendEmailVerification();
          emit(AuthStateNeedsVerification(
            isLoading: false,
            townList: event.townList,
          ));
        } on Exception catch (e) {
          emit(AuthStateRegistering(
              exception: e,
              isLoading: false,
              townList: event.townList,
              town: event.town));
        }
      },
    );

    on<AuthEventDropDownTownChosen>(
      (event, emit) {
        if (state is AuthStateLoggedOut) {
          emit(AuthStateLoggedOut(
              exception: null,
              isLoading: false,
              townList: event.townList,
              town: event.townName));
        } else if (state is AuthStateRegistering) {
          emit(AuthStateRegistering(
              exception: null,
              isLoading: false,
              townList: event.townList,
              town: event.townName));
        }
      },
    );

    //initialise
    on<AuthEventInitialise>(
      (event, emit) async {
        await provider.initialize();
        final townCount = await AppDocumentData.townCount();
        final db = FirebaseCloudStorage();
        final user = provider.currentUser;
        if (townCount != await db.getTownCount()) {
          await AppDocumentData.storeTownList(await db.getAllTown());
        }
        final townList = await AppDocumentData.getTownList();
        if (user == null) {
          emit(
            AuthStateLoggedOut(
              exception: null,
              isLoading: false,
              townList: townList,
              town: await AppDocumentData.getTownName(),
            ),
          );
        } else if (!user.isEmailVerified) {
          emit(AuthStateNeedsVerification(
            isLoading: false,
            townList: event.townList,
          ));
        } else {
          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
            townList: event.townList,
          ));
        }
      },
    );

    //log in
    on<AuthEventLogIn>(
      (event, emit) async {
        final townName = await AppDocumentData.getTownName();
        emit(
          AuthStateLoggedOut(
            exception: null,
            isLoading: true,
            loadingText: 'Please wait while I log you in.',
            townList: event.townList,
            town: townName,
          ),
        );
        final email = event.email;
        final password = event.password;
        try {
          final user = await provider.logIn(
            email: email,
            password: password,
          );

          if (!user.isEmailVerified) {
            emit(
              AuthStateLoggedOut(
                exception: null,
                isLoading: false,
                townList: event.townList,
                town: townName,
              ),
            );

            emit(AuthStateNeedsVerification(
              isLoading: false,
              townList: event.townList,
            ));
          } else {
            emit(
              AuthStateLoggedOut(
                town: townName,
                exception: null,
                isLoading: false,
                townList: event.townList,
              ),
            );
            emit(AuthStateLoggedIn(
              user: user,
              isLoading: false,
              townList: event.townList,
            ));
          }
        } on Exception catch (e) {
          emit(
            AuthStateLoggedOut(
              town: townName,
              exception: e,
              isLoading: false,
              townList: event.townList,
            ),
          );
        }
      },
    );

    //logout
    on<AuthEventLogOut>(
      (event, emit) async {
        final town = await AppDocumentData.getTownName();
        try {
          await provider.logOut();
          emit(
            AuthStateLoggedOut(
              exception: null,
              isLoading: false,
              townList: event.townList,
              town: town,
            ),
          );
        } on Exception catch (e) {
          emit(
            AuthStateLoggedOut(
              exception: e,
              isLoading: false,
              townList: event.townList,
              town: town,
            ),
          );
        }
      },
    );
  }
}
