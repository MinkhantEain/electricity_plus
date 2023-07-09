import "package:electricity_plus/services/auth/auth_provider.dart";
import 'package:electricity_plus/services/auth/auth_user.dart';
import 'package:electricity_plus/services/auth/firebase_auth_provider.dart';
import 'package:electricity_plus/services/models/users.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
    required String passwordReEntry,
    required String name,
  }) =>
      provider.createUser(
        email: email,
        name: name,
        password: password,
        passwordReEntry: passwordReEntry,
      );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> sendPasswordReset({required String email}) =>
      provider.sendPasswordReset(email: email);

}
