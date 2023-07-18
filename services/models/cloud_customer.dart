import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/material.dart';

@immutable
class CloudCustomer implements Comparable {
  final String documentId;
  final String bookId;
  final String meterId;
  final String name;
  final String lastReadDate;
  final String address;
  final DocumentReference<Map<String, dynamic>> lastHistory;
  final num lastUnit;
  final num adder;
  final num horsePowerUnits;
  final num meterMultiplier;
  final num debt;
  final bool flag;
  final bool hasRoadLightCost;

  const CloudCustomer(
      {required this.documentId,
      required this.bookId,
      required this.meterId,
      required this.name,
      required this.address,
      required this.lastUnit,
      required this.flag,
      required this.lastReadDate,
      required this.debt,
      required this.adder,
      required this.horsePowerUnits,
      required this.meterMultiplier,
      required this.hasRoadLightCost,
      required this.lastHistory});

  CloudCustomer updateLastHistory(DocumentReference<Map<String, dynamic>> newLastHistory) {
    return CloudCustomer(
      documentId: documentId,
      bookId: bookId,
      meterId: meterId,
      name: name,
      address: address,
      lastUnit: lastUnit,
      flag: flag,
      lastReadDate: lastReadDate,
      debt: debt,
      adder: adder,
      horsePowerUnits: horsePowerUnits,
      meterMultiplier: meterMultiplier,
      hasRoadLightCost: hasRoadLightCost,
      lastHistory: newLastHistory,
    );
  }

  ///deduct the amount from debt, can be negative to add
  CloudCustomer debtDeduction({required deductAmount}) {
    return CloudCustomer(
      documentId: documentId,
      bookId: bookId,
      meterId: meterId,
      name: name,
      address: address,
      lastUnit: lastUnit,
      flag: flag,
      lastReadDate: lastReadDate,
      debt: debt - (deductAmount),
      adder: adder,
      horsePowerUnits: horsePowerUnits,
      meterMultiplier: meterMultiplier,
      hasRoadLightCost: hasRoadLightCost,
      lastHistory: lastHistory,
    );
  }

  Map<String, dynamic> dataFieldMap() => {
        bookIdField: bookId,
        meterIdField: meterId,
        nameField: name,
        addressField: address,
        lastUnitField: lastUnit,
        lastHistoryField: lastHistory,
        lastReadDateField: lastReadDate,
        flagField: flag,
        adderField: adder,
        debtField: debt,
        horsePowerUnitsField: horsePowerUnits,
        meterMultiplierField: meterMultiplier,
        hasRoadLightCostField: hasRoadLightCost,
      };

  Map<String, dynamic> toJson() => {
        'documentId': documentId,
        bookIdField: bookId,
        meterIdField: meterId,
        nameField: name,
        addressField: address,
        lastUnitField: lastUnit,
        lastHistoryField: lastHistory,
        flagField: flag,
        adderField: adder,
        debtField: debt,
        horsePowerUnitsField: horsePowerUnits,
        meterMultiplierField: meterMultiplier,
        hasRoadLightCostField: hasRoadLightCost,
      };

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
        lastReadDate = json[lastReadDateField].toString(),
        horsePowerUnits = json['horsePowerUnits'],
        meterMultiplier = json['meterMultiplier'],
        hasRoadLightCost = json['hasRoadLightCost'],
        lastHistory = json[lastHistoryField];

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
        lastReadDate = snapshot.data()[lastReadDateField].toString(),
        horsePowerUnits = snapshot.data()[horsePowerUnitsField],
        meterMultiplier = snapshot.data()[meterMultiplierField],
        hasRoadLightCost = snapshot.data()[hasRoadLightCostField],
        debt = snapshot.data()[debtField],
        lastHistory = snapshot.data()[lastHistoryField];

  CloudCustomer.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        bookId = snapshot.data()![bookIdField],
        meterId = snapshot.data()![meterIdField],
        name = snapshot.data()![nameField],
        address = snapshot.data()![addressField],
        lastUnit = snapshot.data()![lastUnitField],
        flag = snapshot.data()![flagField],
        lastReadDate = snapshot.data()![lastReadDateField],
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
debt: $debt
lastUnit: $lastUnit
flag: $flag
adder: $adder
horsePowerUnits: $horsePowerUnits
meterMultiplier: $meterMultiplier
hasRoadLightCost: $hasRoadLightCost
""";
  }

  @override
  int compareTo(dynamic other) {
    other as CloudCustomer;
    final thisCodeUnits = bookId.codeUnits.toList();
    final otherCodeUnits = other.bookId.codeUnits.toList();
    for (int i = 0; i < thisCodeUnits.length; i++) {
      if (thisCodeUnits[i] > otherCodeUnits[i]) {
        return 1;
      } else if (thisCodeUnits[i] < otherCodeUnits[i]) {
        return -1;
      } else {
        continue;
      }
    }
    return 0;
  }
}
