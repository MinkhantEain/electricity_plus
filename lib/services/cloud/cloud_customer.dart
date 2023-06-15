import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudCustomer {
  final String documentId;
  final num id;
  final String bookId;
  final String meterNumber;
  final String customerName;
  final String customerAddress;
  final num oldUnit;
  final num? newUnit;

  const CloudCustomer({
    required this.documentId,
    required this.id,
    required this.bookId,
    required this.meterNumber,
    required this.customerName,
    required this.customerAddress,
    required this.oldUnit,
    this.newUnit
  });

  CloudCustomer.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        id = snapshot.data()[idFieldName],
        bookId = snapshot.data()[bookIdFieldName],
        meterNumber = snapshot.data()[meterNumberFieldName],
        customerName = snapshot.data()[customerNameFieldName],
        customerAddress = snapshot.data()[customerAddressFieldName],
        oldUnit = snapshot.data()[oldUnitFieldName],
        newUnit = snapshot.data()[newUnitFieldName];
}
