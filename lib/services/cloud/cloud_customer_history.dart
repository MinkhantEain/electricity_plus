import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudCustomerHistory {
  final String documentId;
  final String date;
  final String imageUrl;
  final String comment;
  final String inspector;
  final num previousUnit;
  final num newUnit;
  final num priceAtm;
  final num serviceChargeAtm;
  final num cost;
  final num horsePowerPerUnitCostAtm;
  final num horsePowerUnits;
  final num meterMultiplier;
  final bool isVoided;
  final bool isPaid;
  final num roadLightPrice;


  const CloudCustomerHistory({
    required this.documentId,
    required this.previousUnit,
    required this.newUnit,
    required this.priceAtm,
    required this.cost,
    required this.date,
    required this.imageUrl,
    required this.comment,
    required this.isVoided,
    required this.isPaid,
    required this.inspector,
    required this.serviceChargeAtm,
    required this.horsePowerPerUnitCostAtm,
    required this.horsePowerUnits,
    required this.meterMultiplier,
    required this.roadLightPrice,
  });

  CloudCustomerHistory.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) 
  : documentId = snapshot.id,
  previousUnit = snapshot.data()[previousUnitField],
  newUnit = snapshot.data()[newUnitField],
  priceAtm = snapshot.data()[priceAtmField],
  serviceChargeAtm = snapshot.data()[priceAtmField],
  cost = snapshot.data()[costField],
  date = snapshot.data()[dateField],
  imageUrl = snapshot.data()[imageUrlField],
  comment = snapshot.data()[commentField],
  isVoided = snapshot.data()[isVoidedField],
  isPaid = snapshot.data()[isPaidField],
  inspector = snapshot.data()[inspectorField],
  horsePowerPerUnitCostAtm = snapshot.data()[horsePowerPerUnitCostAtmField],
  horsePowerUnits = snapshot.data()[horsePowerUnitsField],
  meterMultiplier = snapshot.data()[meterMultiplierField],
  roadLightPrice = snapshot.data()[roadLightPriceField];

  @override
  String toString() {
    return """
documentId: $documentId
previoudUnit: $previousUnit
newUnit: $newUnit
priceATM: $priceAtm
serviceCharge: $serviceChargeAtm
cost: $cost
date: $date
imageUrl: $imageUrl
comment: $comment
isVoided: $isVoided
isPaid: $isPaid
inspector: $inspector
horsePowerCostAtm = $horsePowerPerUnitCostAtm
horsePowerUnits = $horsePowerUnits
meterMultiplier = $meterMultiplier
""";
  }
}
