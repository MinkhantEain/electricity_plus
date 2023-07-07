import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';

class CloudFlag {
  final String documentId;
  final String inspector;
  final String date;
  final String imageUrl;
  final String comment;
  final bool isResolved;

  const CloudFlag({required this.date,
  required this.comment,
  required this.documentId,
  required this.imageUrl,
  required this.inspector,
  required this.isResolved});

  CloudFlag.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) :
  documentId = snapshot.id,
  comment = snapshot.data()![commentField],
  date = snapshot.data()![dateField],
  imageUrl = snapshot.data()![imageUrlField],
  inspector = snapshot.data()![inspectorField],
  isResolved = snapshot.data()![isResolvedField];

  CloudFlag.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) :
  documentId = snapshot.id,
  comment = snapshot.data()[commentField],
  date = snapshot.data()[dateField],
  imageUrl = snapshot.data()[imageUrlField],
  inspector = snapshot.data()[inspectorField],
  isResolved = snapshot.data()[isResolvedField];
}