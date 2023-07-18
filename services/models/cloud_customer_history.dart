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
  final num roadLightPrice;
  final bool isVoided;
  final bool isPaid;
  final num paidAmount;
  final num meterAllowance;

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
    required this.paidAmount,
    required this.inspector,
    required this.isPaid,
    required this.serviceChargeAtm,
    required this.horsePowerPerUnitCostAtm,
    required this.horsePowerUnits,
    required this.meterMultiplier,
    required this.roadLightPrice,
    required this.meterAllowance,
  });

  static CloudCustomerHistory getBlankHistory({
    num? previousUnit,
    num? newUnit,
    required String inspector,
    required String documentId,
  }) {
    return CloudCustomerHistory(
      documentId: documentId,
      previousUnit: previousUnit ?? 0,
      newUnit: newUnit ?? 0,
      priceAtm: 0,
      cost: 0,
      date: DateTime.now().toString(),
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/electricityplus-a6572.appspot.com/o/newUser%2Fsoil.jpg?alt=media&token=93cdbd32-72a3-4992-a134-226d465c340f',
      comment: 'Blank history',
      isVoided: false,
      paidAmount: 0,
      inspector: inspector,
      isPaid: true,
      serviceChargeAtm: 0,
      horsePowerPerUnitCostAtm: 0,
      horsePowerUnits: 0,
      meterMultiplier: 0,
      roadLightPrice: 0,
      meterAllowance: 0,
    );
  }

  num getUnitUsed() {
    return (newUnit - previousUnit) * meterMultiplier;
  }

  num getHorsePowerCost() {
    return (newUnit - previousUnit) == 0
        ? 0
        : horsePowerUnits * horsePowerPerUnitCostAtm;
  }

  num getCost() {
    return getUnitUsed() * priceAtm + getHorsePowerCost();
  }

  num getTotalCost() {
    return cost;
  }

  num meterAllowanceDebtChangeAmt({required num newMeterAllowance}) {
    return (newMeterAllowance - meterAllowance) * priceAtm;
  }

  ///Note: before calling this function, it is advised to cann deductMeterAllowanceBill
  ///to see how much the bill is deducted before adding meter allowance.
  ///changes the cost, meterallowance value
  CloudCustomerHistory changeMeterAllowance({required num newMeterAllowance}) {
    return CloudCustomerHistory(
      documentId: documentId,
      previousUnit: previousUnit,
      newUnit: newUnit,
      priceAtm: priceAtm,
      cost: cost - (newMeterAllowance - meterAllowance) * priceAtm,
      date: date,
      imageUrl: imageUrl,
      comment: comment,
      isVoided: isVoided,
      paidAmount: paidAmount,
      inspector: inspector,
      isPaid: isPaid,
      serviceChargeAtm: serviceChargeAtm,
      horsePowerPerUnitCostAtm: horsePowerPerUnitCostAtm,
      horsePowerUnits: horsePowerUnits,
      meterMultiplier: meterMultiplier,
      roadLightPrice: roadLightPrice,
      meterAllowance: newMeterAllowance,
    );
  }

  num unpaidAmount() {
    return cost - paidAmount;
  }

  CloudCustomerHistory updatePaidAmount({required num receiptPaidAmount}) {
    final hasPaid = receiptPaidAmount >= cost ? true : false;
    return CloudCustomerHistory(
        documentId: documentId,
        previousUnit: previousUnit,
        newUnit: newUnit,
        priceAtm: priceAtm,
        cost: cost,
        date: date,
        imageUrl: imageUrl,
        comment: comment,
        isVoided: isVoided,
        paidAmount: receiptPaidAmount,
        inspector: inspector,
        isPaid: hasPaid,
        serviceChargeAtm: serviceChargeAtm,
        horsePowerPerUnitCostAtm: horsePowerPerUnitCostAtm,
        horsePowerUnits: horsePowerUnits,
        meterMultiplier: meterMultiplier,
        roadLightPrice: roadLightPrice,
        meterAllowance: meterAllowance);
  }

  Map<String, dynamic> dataFieldMap() => {
        previousUnitField: previousUnit,
        newUnitField: newUnit,
        priceAtmField: priceAtm,
        serviceChargeAtmField: serviceChargeAtm,
        costField: cost,
        dateField: date,
        imageUrlField: imageUrl,
        commentField: comment,
        isPaidField: isPaid,
        isVoidedField: isVoided,
        paidAmountField: paidAmount,
        inspectorField: inspector,
        horsePowerPerUnitCostAtmField: horsePowerPerUnitCostAtm,
        horsePowerUnitsField: horsePowerUnits,
        meterMultiplierField: meterMultiplier,
        roadLightPriceField: roadLightPrice,
        meterAllowanceField: meterAllowance,
      };

  CloudCustomerHistory.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        previousUnit = snapshot.data()[previousUnitField],
        newUnit = snapshot.data()[newUnitField],
        priceAtm = snapshot.data()[priceAtmField],
        serviceChargeAtm = snapshot.data()[serviceChargeAtmField],
        cost = snapshot.data()[costField],
        date = snapshot.data()[dateField],
        imageUrl = snapshot.data()[imageUrlField],
        comment = snapshot.data()[commentField],
        isPaid = snapshot.data()[isPaidField],
        isVoided = snapshot.data()[isVoidedField],
        paidAmount = snapshot.data()[paidAmountField],
        inspector = snapshot.data()[inspectorField],
        horsePowerPerUnitCostAtm =
            snapshot.data()[horsePowerPerUnitCostAtmField],
        horsePowerUnits = snapshot.data()[horsePowerUnitsField],
        meterMultiplier = snapshot.data()[meterMultiplierField],
        meterAllowance = snapshot.data()[meterAllowanceField],
        roadLightPrice = snapshot.data()[roadLightPriceField];

  CloudCustomerHistory.fromDocSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        previousUnit = snapshot.data()![previousUnitField],
        newUnit = snapshot.data()![newUnitField],
        priceAtm = snapshot.data()![priceAtmField],
        serviceChargeAtm = snapshot.data()![serviceChargeAtmField],
        cost = snapshot.data()![costField],
        date = snapshot.data()![dateField],
        isPaid = snapshot.data()![isPaidField],
        imageUrl = snapshot.data()![imageUrlField],
        comment = snapshot.data()![commentField],
        isVoided = snapshot.data()![isVoidedField],
        paidAmount = snapshot.data()![paidAmountField],
        inspector = snapshot.data()![inspectorField],
        horsePowerPerUnitCostAtm =
            snapshot.data()![horsePowerPerUnitCostAtmField],
        horsePowerUnits = snapshot.data()![horsePowerUnitsField],
        meterMultiplier = snapshot.data()![meterMultiplierField],
        meterAllowance = snapshot.data()![meterAllowanceField],
        roadLightPrice = snapshot.data()![roadLightPriceField];

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
paidAmount: $paidAmount
isPaid: $isPaid
inspector: $inspector
meterAllowance: $meterAllowance
horsePowerCostAtm = $horsePowerPerUnitCostAtm
horsePowerUnits = $horsePowerUnits
meterMultiplier = $meterMultiplier
""";
  }
}
