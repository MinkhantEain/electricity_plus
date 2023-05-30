import 'package:electricity_plus/firebase_options.dart';
import 'package:electricity_plus/services/auth/auth_user.dart';
import 'package:electricity_plus/services/auth/auth_provider.dart';
import 'package:electricity_plus/services/auth/auth_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-passowrd") {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
  
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
  }
}
