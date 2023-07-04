import 'package:cloud_firestore/cloud_firestore.dart';

class Town {
  final String townName;
  const Town({required this.townName});

  Town.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : townName = snapshot.id;

  @override
  String toString() {
    return townName;
  }
}
