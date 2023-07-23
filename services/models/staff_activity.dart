import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';

class StaffActivity {
  String documentId;
  String bookId;
  String name;
  String address;
  DocumentReference<Map<String, dynamic>> reference;
  num paidAmount;
  String date;

  Map<String, dynamic> dataFieldMap() {
    return {
      bookIdField: bookId,
      nameField: name,
      addressField: address,
      referenceField: reference,
      paidAmountField: paidAmount,
      dateField: date,
    };
  }

  StaffActivity.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) :
  documentId = snapshot.id,
  bookId = snapshot.data()![bookIdField],
  name = snapshot.data()![nameField],
  address = snapshot.data()![addressField],
  reference = snapshot.data()![referenceField],
  paidAmount = snapshot.data()![paidAmountField],
  date = snapshot.data()![dateField];

  StaffActivity.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) :
  documentId = snapshot.id,
  bookId = snapshot.data()[bookIdField],
  name = snapshot.data()[nameField],
  address = snapshot.data()[addressField],
  reference = snapshot.data()[referenceField],
  paidAmount = snapshot.data()[paidAmountField],
  date = snapshot.data()[dateField];

  @override
  String toString() {
    return dataFieldMap.toString();
  }
}