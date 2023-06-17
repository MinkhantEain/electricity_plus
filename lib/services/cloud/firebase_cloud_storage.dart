import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/cloud_customer_history.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'dart:developer' as dev show log;

class FirebaseCloudStorage {
  final customersDetailsCollection =
      FirebaseFirestore.instance.collection(customerDetailsCollection);
  final priceCollectionDoc =
      FirebaseFirestore.instance.collection(priceCollection).doc(priceDoc);

  Future<num> get getPrice => priceCollectionDoc.get().then(
        (DocumentSnapshot doc) {
          final price = doc.data() as Map<String, dynamic>;
          return price[pricePerUnitField] as num;
        },
        onError: (_) => throw CouldNotGetPriceException(),
      );

  Future<num> get getServiceCharge => priceCollectionDoc.get().then(
        (DocumentSnapshot doc) {
          final serviceCharge = doc.data() as Map<String, dynamic>;
          return serviceCharge[serviceChargeField] as num;
        },
        onError: (_) => throw CouldNotGetServiceChargeException(),
      );

  void setPrice(String newPrice, String token) {
    num? parsedNewPrice = num.tryParse(newPrice);
    if (token != 'sf2465<>100600') {
      throw UnAuthorizedPriceSetException();
    }
    if (parsedNewPrice != null && parsedNewPrice != 0) {
      priceCollectionDoc.update({pricePerUnitField: parsedNewPrice});
    } else {
      throw CouldNotSetPriceException();
    }
  }

  void setServiceCharge(String newServiceCharge, String token) {
    num? parsedNewServiceCharge = num.tryParse(newServiceCharge);
    if (token != 'sf2465<>100600') {
      throw UnAuthorizedPriceSetException();
    }
    if (parsedNewServiceCharge != null && parsedNewServiceCharge != 0) {
      priceCollectionDoc.update({serviceChargeField: parsedNewServiceCharge});
    } else {
      throw CouldNotSetServiceChargeException();
    }
  }



  // Future<void> updateNote({
  //   required String documentId,
  //   required String text,
  // }) async {
  //   try {
  //     await notes.doc(documentId).update({textFieldName: text});
  //   } catch (e) {
  //     throw CouldNotUpdateNoteException();
  //   }
  // }

  Future<String> printReceipt(
      {required CloudCustomer customer,
      required CloudCustomerHistory history}) async {
        dev.log("print receipt is executed");
    return '''
            Receipt ID: ${history.documentId}
            -Details-
            Date: ${history.date}
            Name: ${customer.name}
            Meter ID: ${customer.meterId}
            Address: ${customer.address}
            Previous Reading: ${history.previousUnit}
            New Reading: ${history.newUnit}
            Unit Used: ${(history.newUnit - customer.lastUnit)}
            Price Per Unit: ${history.priceAtm}
            Service Charge: ${history.serviceCharge}
            Cost: ${(history.newUnit - customer.lastUnit) * history.priceAtm + history.serviceCharge}
    ''';
  }

  Future<void> updateUnit({
    required String documentId,
    required int newUnit,
  }) async {
    try {
      await customersDetailsCollection
          .doc(documentId)
          .update({newUnitFieldName: newUnit});
    } catch (e) {
      throw CouldNotUpdateUnitException();
    }
  }

  // Future<CloudNote> createNewnotes({required String ownerUserId}) async {
  //   final document = await notes
  //       .add({ownerUserIdFieldNames: ownerUserId, textFieldName: ''});
  //   final fetchedNote = await document.get();
  //   return CloudNote(
  //     documentId: fetchedNote.id,
  //     ownerUserId: ownerUserId,
  //     text: '',
  //   );
  // }

  // Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
  //     notes.snapshots().map((event) => event.docs
  //         .map((doc) => CloudNote.fromSnapshot(doc))
  //         .where((note) => note.ownerUserId == ownerUserId));

  // Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
  //   try {
  //     return await notes
  //         .where(
  //           ownerUserIdFieldNames,
  //           isEqualTo: ownerUserId,
  //         )
  //         .get()
  //         .then(
  //           (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
  //         );
  //   } catch (e) {
  //     throw CouldNoteGetAllNotesException();
  //   }
  // }
  Future<CloudCustomerHistory> getCustomerHistory(
      {required CloudCustomer customer}) async {
    final customerHistoryCollection = FirebaseFirestore.instance.collection(
        '$customerDetailsCollection/${customer.documentId}/$historyCollection');
    final result = await customerHistoryCollection
        .orderBy(dateField, descending: true)
        .get()
        .then((value) => CloudCustomerHistory.fromSnapshot(value.docs.first));
    return result;
  }

  Future<Iterable<CloudCustomerHistory>> getCustomerAllHistory({
    required CloudCustomer customer
  }) async {
    final customerHistoryCollection = FirebaseFirestore.instance.collection(
        '$customerDetailsCollection/${customer.documentId}/$historyCollection');
    final result = await customerHistoryCollection
        .orderBy(dateField, descending: true)
        .get()
        .then((value) => value.docs.map((doc) => CloudCustomerHistory.fromSnapshot(doc)));
    return result;
  }

  Future<Iterable<CloudCustomer>> getCustomer({
    // int? id,
    required String? bookId,
    required String? meterNumber,
  }) async {
    try {
      if (bookId != null) {
        return await customersDetailsCollection
            .where(bookIdField, isEqualTo: bookId)
            .get()
            .then((value) =>
                value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));
      }
      if (meterNumber != null) {
        return await customersDetailsCollection
            .where(meterIdField, isEqualTo: meterNumber)
            .get()
            .then((value) =>
                value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));
      }
      throw CouldNotGetCustomerException();
      // return await customersDetailsCollection.where(meterIdField, isEqualTo: 'E1D177111').get()
      // .then((value) => value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));
    } catch (e) {
      throw CouldNotGetCustomerException();
    }
  }

  Future<Iterable<CloudCustomer>> allCustomer() => customersDetailsCollection
  .get().then((value) => value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
