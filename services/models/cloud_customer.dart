import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudCustomer {
  final String documentId;
  final String bookId;
  final String meterId;
  final String name;
  final String address;
  final DocumentReference<Map<String, dynamic>> lastHistory;
  final num lastUnit;
  final num adder;
  final num horsePowerUnits;
  final num meterMultiplier;
  final num debt;
  final bool flag;
  final bool hasRoadLightCost;

  const CloudCustomer({
    required this.documentId,
    required this.bookId,
    required this.meterId,
    required this.name,
    required this.address,
    required this.lastUnit,
    required this.flag,
    required this.debt,
    required this.adder,
    required this.horsePowerUnits,
    required this.meterMultiplier,
    required this.hasRoadLightCost,
    required this.lastHistory
  });


  CloudCustomer.fromJson(Map<String, dynamic> json)
      : documentId = json['documentId'],
        bookId = json['bookId'],
        meterId = json['meterId'],
        name = json['name'],
        address = json['address'],
        lastUnit = json['lastUnit'],
        flag = json['flag'],
        debt = json[debtField],
        adder = json['adder'],
        horsePowerUnits = json['horsePowerUnits'],
        meterMultiplier = json['meterMultiplier'],
        hasRoadLightCost = json['hasRoadLightCost'],
        lastHistory = json[lastHistoryField];

  Map<String, dynamic> toJson() => {
        'documentId': documentId,
        'bookId': bookId,
        'meterId': meterId,
        'name': name,
        'address': address,
        'lastUnit': lastUnit,
        'flag': flag,
        'adder': adder,
        debtField : debt,
        'horsePowerUnits': horsePowerUnits,
        'meterMultiplier': meterMultiplier,
        'hasRoadLightCost': hasRoadLightCost,
      };

  CloudCustomer.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        bookId = snapshot.data()[bookIdField],
        meterId = snapshot.data()[meterIdField],
        name = snapshot.data()[nameField],
        address = snapshot.data()[addressField],
        lastUnit = snapshot.data()[lastUnitField],
        flag = snapshot.data()[flagField],
        adder = snapshot.data()[adderField],
        horsePowerUnits = snapshot.data()[horsePowerUnitsField],
        meterMultiplier = snapshot.data()[meterMultiplierField],
        hasRoadLightCost = snapshot.data()[hasRoadLightCostField],
        debt = snapshot.data()[debtField],
        lastHistory = snapshot.data()[lastHistoryField];
  
  CloudCustomer.fromDocSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        bookId = snapshot.data()![bookIdField],
        meterId = snapshot.data()![meterIdField],
        name = snapshot.data()![nameField],
        address = snapshot.data()![addressField],
        lastUnit = snapshot.data()![lastUnitField],
        flag = snapshot.data()![flagField],
        debt = snapshot.data()![debtField],
        adder = snapshot.data()![adderField],
        horsePowerUnits = snapshot.data()![horsePowerUnitsField],
        meterMultiplier = snapshot.data()![meterMultiplierField],
        hasRoadLightCost = snapshot.data()![hasRoadLightCostField],
        lastHistory = snapshot.data()![lastHistoryField];


  @override
  String toString() {
    return """
documentId: $documentId
bookId: $bookId
meterId: $meterId
name: $name
address: $address
lastUnit: $lastUnit
flag: $flag
adder: $adder
horsePowerUnits: $horsePowerUnits
meterMultiplier: $meterMultiplier
hasRoadLightCost: $hasRoadLightCost
""";
  }
}
