import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';

class CloudIssue {
  final String documentId;
  final String comment;
  final String date;
  final DocumentReference<Map<String, dynamic>> reference;

  const CloudIssue({required this.date,
  required this.comment,
  required this.documentId,
  required this.reference});

  CloudIssue.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) :
  documentId = snapshot.id,
  comment = snapshot.data()![commentField],
  date = snapshot.data()![dateField],
  reference = snapshot.data()![referenceField];

  CloudIssue.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) :
  documentId = snapshot.id,
  comment = snapshot.data()[commentField],
  date = snapshot.data()[dateField],
  reference = snapshot.data()[referenceField];
}