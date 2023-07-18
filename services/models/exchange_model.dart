import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';

class CloudExchangeHistory {
  final String bookId;
  final String tempBookId;
  final String oldMeterId;
  final String newMeterId;
  final String name;
  final String address;
  final String exchangeReason;
  final String date;
  final num previousUnit;
  final num finalUnit;
  final num unitUsed;
  final String calculationDetails;
  final num cost;
  final num newMeterInitialReading;
  final num costOfNewMeter;
  final num totalCost;
  final String documentId;

  const CloudExchangeHistory({
    required this.documentId,
    required this.address,
    required this.bookId,
    required this.tempBookId,
    required this.oldMeterId,
    required this.newMeterId,
    required this.name,
    required this.exchangeReason,
    required this.previousUnit,
    required this.finalUnit,
    required this.unitUsed,
    required this.calculationDetails,
    required this.cost,
    required this.newMeterInitialReading,
    required this.date,
    required this.costOfNewMeter,
    required this.totalCost,
  });

  Map<String, dynamic> dataFieldMap() {
    return {
      addressField: address,
      bookIdField: bookId,
      tempBookIdField: tempBookId,
      oldMeterIdField: oldMeterId,
      newMeterIdField: newMeterId,
      nameField: name,
      dateField : date,
      exchangeReasonField: exchangeReason,
      previousUnitField: previousUnit,
      finalUnitField: finalUnit,
      unitUsedField: unitUsed,
      calculationDetailsField: calculationDetails,
      costField: cost,
      newMeterInitialReadingField: newMeterInitialReading,
      costOfNewMeterField: costOfNewMeter,
      totalCostField: totalCost,
    };
  }

  CloudExchangeHistory.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        address = snapshot.data()[addressField],
        bookId = snapshot.data()[bookIdField],
        tempBookId = snapshot.data()[tempBookIdField],
        oldMeterId = snapshot.data()[oldMeterIdField],
        newMeterId = snapshot.data()[newMeterIdField],
        name = snapshot.data()[nameField],
        date = snapshot.data()[dateField],
        exchangeReason = snapshot.data()[exchangeReasonField],
        previousUnit = snapshot.data()[previousUnitField],
        finalUnit = snapshot.data()[finalUnitField],
        unitUsed = snapshot.data()[unitUsedField],
        calculationDetails = snapshot.data()[calculationDetailsField],
        cost = snapshot.data()[costField],
        newMeterInitialReading = snapshot.data()[newMeterInitialReadingField],
        costOfNewMeter = snapshot.data()[costOfNewMeterField],
        totalCost = snapshot.data()[totalCostField];
}
