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
  final bool flag;

  const CloudCustomer({
    required this.documentId,
    required this.bookId,
    required this.meterId,
    required this.name,
    required this.address,
    required this.lastUnit,
    required this.flag,
  });

  CloudCustomer.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        bookId = snapshot.data()[bookIdField],
        meterId = snapshot.data()[meterIdField],
        name = snapshot.data()[nameField],
        address = snapshot.data()[addressField],
        lastUnit = snapshot.data()[lastUnitField],
        flag = snapshot.data()[flagField];
  
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
""";
  }
}
