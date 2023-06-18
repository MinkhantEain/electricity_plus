import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudCustomerHistory {
  final String documentId;
  final num previousUnit;
  final num newUnit;
  final num priceAtm;
  final num serviceCharge;
  final num cost;
  final String date;
  final String imageUrl;
  final String comment;
  final bool isVoided;

  const CloudCustomerHistory({
    required this.documentId,
    required this.previousUnit,
    required this.newUnit,
    required this.priceAtm,
    required this.serviceCharge,
    required this.cost,
    required this.date,
    required this.imageUrl,
    required this.comment,
    required this.isVoided,
  });

  CloudCustomerHistory.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) 
  : documentId = snapshot.id,
  previousUnit = snapshot.data()[previousUnitField],
  newUnit = snapshot.data()[newUnitField],
  priceAtm = snapshot.data()[priceAtmField],
  serviceCharge = snapshot.data()[priceAtmField],
  cost = snapshot.data()[costField],
  date = snapshot.data()[dateField],
  imageUrl = snapshot.data()[imageUrlField],
  comment = snapshot.data()[commentField],
  isVoided = snapshot.data()[isVoidedField];

  @override
  String toString() {
    return """
documentId: $documentId
previoudUnit: $previousUnit
newUnit: $newUnit
priceATM: $priceAtm
serviceCharge: $serviceCharge
cost: $cost
date: $date
imageUrl: $imageUrl
comment: $comment
isVoided: $isVoided
""";
  }
}
