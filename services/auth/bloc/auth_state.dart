import 'package:electricity_plus/services/others/town.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:electricity_plus/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  final Iterable<Town> townList;
  const AuthState({
    required this.isLoading,
    required this.townList,
    this.loadingText = "Please wait a moment",
  });
}

class AuthStateUninitialised extends AuthState {
  const AuthStateUninitialised({
    required bool isLoading,
    required Iterable<Town> townList,
  }) : super(isLoading: isLoading, townList: townList);
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  final String town;
  const AuthStateRegistering({
    required this.exception,
    required bool isLoading,
    required Iterable<Town> townList,
    required this.town,
  }) : super(isLoading: isLoading, townList: townList);
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({
    required this.user,
    required bool isLoading,
    required Iterable<Town> townList,
  }) : super(isLoading: isLoading, townList: townList);
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  final String town;
  const AuthStateLoggedOut(
      {required this.exception,
      required bool isLoading,
      required Iterable<Town> townList,
      String? loadingText,
      required this.town})
      : super(
          isLoading: isLoading,
          loadingText: loadingText,
          townList: townList
        );

  @override
  List<Object?> get props => [exception, isLoading, townList, town];
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({
    required bool isLoading,
    required Iterable<Town> townList,
  }) : super(isLoading: isLoading, townList: townList);
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;
  const AuthStateForgotPassword(
      {required this.exception,
      required this.hasSentEmail,
      required Iterable<Town> townList,
      required bool isLoading})
      : super(isLoading: isLoading, townList: townList);
}
