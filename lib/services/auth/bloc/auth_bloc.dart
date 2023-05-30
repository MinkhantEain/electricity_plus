import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electricity_plus/services/auth/auth_provider.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialised(isLoading: true)) {
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    },);

    //send phoneNumber verification
    on<AuthEventSendphoneNumberVerification>(
      (event, emit) async {
        await provider.sendphoneNumberVerification();
        emit(state);
      },
    );

    //forgot password
    on<AuthEventForgotPassword>(
      (event, emit) async {
        emit(const AuthStateForgotPassword(
          exception: null,
          hasSentphoneNumber: false,
          isLoading: false,
        ));
        final phoneNumber = event.phoneNumber;
        if (phoneNumber == null) {
          return; //user just want to go to forgot password screen
        }

        //user wants to actually send a forgot-password phoneNumber
        emit(const AuthStateForgotPassword(
          exception: null,
          hasSentphoneNumber: false,
          isLoading: true,
        ));

        bool didSendphoneNumber;
        Exception? exception;
        try {
          await provider.sendPasswordReset(phoneNumber: phoneNumber);
          didSendphoneNumber = true;
          exception = null;
        } on Exception catch (e) {
          didSendphoneNumber = false;
          exception = e;
        }

        emit(AuthStateForgotPassword(
          exception: exception,
          hasSentphoneNumber: didSendphoneNumber,
          isLoading: false,
        ));
      },
    );

    on<AuthEventRegister>(
      (event, emit) async {
        final phoneNumber = event.phoneNumber;
        final password = event.password;
        try {
          await provider.createUser(
            phoneNumber: phoneNumber,
            password: password,
          );
          await provider.sendphoneNumberVerification();
          emit(const AuthStateNeedsVerification(isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateRegistering(exception: e, isLoading: false));
        }
      },
    );

    //initialise
    on<AuthEventInitialise>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;
        if (user == null) {
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
        } else if (!user.isphoneNumberVerified) {
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      },
    );

    //log in
    on<AuthEventLogIn>(
      (event, emit) async {
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: true,
            loadingText: 'Please wait while I log you in.',
          ),
        );
        final phoneNumber = event.phoneNumber;
        final password = event.password;
        try {
          final user = await provider.login(
            phoneNumber: phoneNumber,
            password: password,
          );
          if (!user.isphoneNumberVerified) {
            emit(
              const AuthStateLoggedOut(
                exception: null,
                isLoading: false,
              ),
            );

            emit(const AuthStateNeedsVerification(isLoading: false));
          } else {
            emit(
              const AuthStateLoggedOut(
                exception: null,
                isLoading: false,
              ),
            );
            emit(AuthStateLoggedIn(user: user, isLoading: false));
          }
        } on Exception catch (e) {
          emit(
            AuthStateLoggedOut(
              exception: e,
              isLoading: false,
            ),
          );
        }
      },
    );

    //logout
    on<AuthEventLogOut>(
      (event, emit) async {
        try {
          await provider.logout();
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
        } on Exception catch (e) {
          emit(
            AuthStateLoggedOut(
              exception: e,
              isLoading: false,
            ),
          );
        }
      },
    );
  }
}
