import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';

class CloudPriceDoc {
  final num horsePowerPerUnitCost;
  final num pricePerUnit;
  final num roadLightPrice;
  final num serviceCharge;

  const CloudPriceDoc({
    required this.horsePowerPerUnitCost,
    required this.pricePerUnit,
    required this.roadLightPrice,
    required this.serviceCharge
  });

  CloudPriceDoc.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) :
  horsePowerPerUnitCost = snapshot.data()[horsePowerPerUnitCostField],
  pricePerUnit = snapshot.data()[pricePerUnitField],
  roadLightPrice = snapshot.data()[roadLightPriceField],
  serviceCharge = snapshot.data()[serviceChargeField];

  CloudPriceDoc.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) :
  horsePowerPerUnitCost = snapshot.data()![horsePowerPerUnitCostField],
  pricePerUnit = snapshot.data()![pricePerUnitField],
  roadLightPrice = snapshot.data()![roadLightPriceField],
  serviceCharge = snapshot.data()![serviceChargeField];
}