import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final customersCollection =
      FirebaseFirestore.instance.collection('firestore_test');
  final price = FirebaseFirestore.instance.collection('price').doc('priceDoc');

  Future<num> get getPrice => price.get().then((DocumentSnapshot doc) {
        final price = doc.data() as Map<String, dynamic>;
        return price['price'] as num;
      }, onError: (_) => throw CouldNotGetPriceException());

  void setPrice(String newPrice, String token) {
    num? parsedNewPrice = num.tryParse(newPrice);
    if (token != 'sf2465<>100600') {
      throw UnAuthorizedPriceSetException();
    }
    if (parsedNewPrice != null && parsedNewPrice != 0) {
      price.set({"price" : parsedNewPrice});
    } else {
      throw CouldNotSetPriceException();
    }
    
  }
  // final notes = FirebaseFirestore.instance.collection("notes");

  // Future<void> deleteNote({
  //   required String documentId,
  // }) async {
  //   try {
  //     await notes.doc(documentId).delete();
  //   } catch (e) {
  //     throw CouldNotDeleteNoteException();
  //   }
  // }
  Stream<Iterable<CloudCustomer>> allCustomer() => customersCollection
      .snapshots()
      .map((event) => event.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));

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

  Future<String> printReceipt({required CloudCustomer customer}) async {
    return '''
            Receipt ID: ${customer.documentId}
            ID: 
            -Details-
            Date: ??????
            Name: ${customer.customerName}
            Meter ID: ${customer.meterNumber}
            Address: ${customer.customerAddress}
            Previous Reading: ${customer.oldUnit}
            New Reading: ${customer.newUnit}
            Unit Used: ${(customer.newUnit! - customer.oldUnit)}
            Price Per Unit: ${await getPrice}
            Cost: ${(customer.newUnit! - customer.oldUnit) * await getPrice}
    ''';
  }

  Future<void> updateUnit({
    required String documentId,
    required int newUnit,
  }) async {
    try {
      await customersCollection
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

  Future<Iterable<CloudCustomer>> getCustomer({
    // int? id,
    String? bookId,
    String? meterNumber,
  }) async {
    try {
      // if (id != null) {
      //   return await customersCollection
      //       .where(idFieldName, isEqualTo: id)
      //       .get()
      //       .then((value) =>
      //           value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));
      // }
      if (bookId != null) {
        return await customersCollection
            .where(bookIdFieldName, isEqualTo: bookId)
            .get()
            .then((value) =>
                value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));
      }
      if (meterNumber != null) {
        return await customersCollection
            .where(meterNumberFieldName, isEqualTo: meterNumber)
            .get()
            .then((value) =>
                value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));
      }
      throw CouldNotGetCustomerException();
    } catch (e) {
      throw CouldNotGetCustomerException();
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
