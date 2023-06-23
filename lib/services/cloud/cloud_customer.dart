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
  final num lastUnit;
  final num adder;
  final num horsePowerUnits;
  final num meterMultiplier;
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
    required this.adder,
    required this.horsePowerUnits,
    required this.meterMultiplier,
    required this.hasRoadLightCost,
  });

  CloudCustomer.fromJson(Map<String, dynamic> json)
      : documentId = json['documentId'],
        bookId = json['bookId'],
        meterId = json['meterId'],
        name = json['name'],
        address = json['address'],
        lastUnit = json['lastUnit'],
        flag = json['flag'],
        adder = json['adder'],
        horsePowerUnits = json['horsePowerUnits'],
        meterMultiplier = json['meterMultiplier'],
        hasRoadLightCost = json['hasRoadLightCost'];

  Map<String, dynamic> toJson() => {
        'documentId': documentId,
        'bookId': bookId,
        'meterId': meterId,
        'name': name,
        'address': address,
        'lastUnit': lastUnit,
        'flag': flag,
        'adder': adder,
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
        hasRoadLightCost = snapshot.data()[hasRoadLightCostField];

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
