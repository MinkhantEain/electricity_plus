import 'package:electricity_plus/services/auth/bloc/auth_state.dart';
import 'package:electricity_plus/services/others/town.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  final Iterable<Town> townList;
  const AuthEvent({required this.townList});
}

class AuthEventInitialise extends AuthEvent {
  const AuthEventInitialise({required Iterable<Town> townList})
      : super(townList: townList);
}

class AuthEventDropDownTownChosen extends AuthEvent {
  final String townName;
  final AuthState state;
  const AuthEventDropDownTownChosen({required Iterable<Town> townList,
  required this.townName, required this.state}) : super(townList: townList);
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogIn(
      {required this.email,
      required this.password,
      required Iterable<Town> townList})
      : super(townList: townList);
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String passwordReEntry;
  final String town;
  const AuthEventRegister({
    required this.email,
    required this.password,
    required this.passwordReEntry,
    required this.name,
    required this.town,
    required Iterable<Town> townList,
  }) : super(townList: townList);
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister({required Iterable<Town> townList})
      : super(townList: townList);
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut({required Iterable<Town> townList})
      : super(townList: townList);
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification({required Iterable<Town> townList})
      : super(townList: townList);
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({
    this.email,
    required Iterable<Town> townList,
  }) : super(townList: townList);
}
