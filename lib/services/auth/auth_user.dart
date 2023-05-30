import "package:firebase_auth/firebase_auth.dart" as firebase_auth show User;
import "package:flutter/material.dart";

@immutable
class AuthUser {
  final String id;
  final bool isEmailVerified;
  final String email;
  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(firebase_auth.User user) =>
      AuthUser(email: user.email!, isEmailVerified: user.emailVerified, id: user.uid,);
}
