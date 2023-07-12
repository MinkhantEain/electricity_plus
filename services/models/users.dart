import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';

class Staff implements Comparable<Staff>{
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

  int userTypeValue() {
    if (userType == undecidedType) {
      return 0;
    } else if (userType == meterReaderType) {
      return 1;
    } else if (userType == cashierType) {
      return 2;
    } else if (userType == managerType) {
      return 3;
    } else if (userType == directorType) {
      return 4;
    } else if (userType == adminType) {
      return 5;
    } else {
      return 0;
    }
  }

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
  
  Staff.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) :
    uid = snapshot.id,
    name = snapshot.data()[nameField],
    email = snapshot.data()[emailField],
    password = snapshot.data()[passwordField],
    isStaff = snapshot.data()[isStaffField],
    userType = snapshot.data()[userTypeField];


  @override
  String toString() {
    return '''
uid: $uid
name: $name
email: $email
password: $password
isStaff: $isStaff
userType: $userType
''';
  }
  
  @override
  int compareTo(other) {
    if (userTypeValue() < other.userTypeValue()) {
      return -1;
    } else if (userTypeValue() == other.userTypeValue()) {
      return 0;
    } else {
      return 1;
    }
  }
}