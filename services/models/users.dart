import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';

class Staff{
  final String uid;
  final String name;
  final String email;
  final String password;
  final bool isStaff;
  final String userType;
  const Staff({
    required this.uid,
    required this.email,
    required this.name,
    required this.password,
    required this.userType,
    required this.isStaff,
  });

  Map<String, dynamic> dataFieldMap() {
    return {
      nameField : name,
      emailField : email,
      passwordField : password,
      isStaffField : isStaff,
      userTypeField : userType,
    };
  }

  Staff.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) :
    uid = snapshot.id,
    name = snapshot.data()![nameField],
    email = snapshot.data()![emailField],
    password = snapshot.data()![passwordField],
    isStaff = snapshot.data()![isStaffField],
    userType = snapshot.data()![userTypeField];
}