import "package:electricity_plus/services/auth/auth_user.dart";

abstract class AuthProvider {
  AuthUser? get currentUser;
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  Future<AuthUser> createUser({
    required String email,
    required String name,
    required String password,
    required String passwordReEntry,
    required String userType,
    required bool isStaff,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> initialize();
  Future<void> sendPasswordReset({required String email});
}