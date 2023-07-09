import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/enums/user_type.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String password;
  final bool isStaff;
  final UserType userType;
  const User({
    required this.uid,
    required this.email,
    required this.name,
    required this.password,
    required this.userType,
    required this.isStaff,
  });

  User.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) :
    uid = snapshot.id,
    name = snapshot.data()![nameField],
    email = snapshot.data()![emailField],
    password = snapshot.data()![passwordField],
    isStaff = snapshot.data()![isStaffField],
    userType = snapshot.data()![userTypeField];
}