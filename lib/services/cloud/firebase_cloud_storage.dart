import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/cloud_customer_history.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev show log;

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseCloudStorage {
  final _customersDetailsCollection =
      FirebaseFirestore.instance.collection(customerDetailsCollection);
  final priceCollectionDoc =
      FirebaseFirestore.instance.collection(priceCollection).doc(priceDoc);

  final firebaseStorage = FirebaseStorage.instance.ref();

  Future<String> get getServerToken => FirebaseFirestore.instance
          .collection('Admin')
          .doc('Details')
          .get()
          .then((DocumentSnapshot doc) {
        final snapshot = doc.data() as Map<String, dynamic>;
        return snapshot['Password'];
      }, onError: (_) => throw CouldNotGetPasswordException());

  CollectionReference<Map<String, dynamic>> getCustomerHistoryCollection(
      CloudCustomer customer) {
    return FirebaseFirestore.instance.collection(
        '$customerDetailsCollection/${customer.documentId}/$historyCollection');
  }

  Future<num> getPreviousValidUnit(CloudCustomer customer) async {
    final historyCollection = getCustomerHistoryCollection(customer);
    final result = await historyCollection
        .where(dateField,
            isLessThanOrEqualTo: DateTime.now().toString().substring(0, 7))
        .where(isVoidedField, isEqualTo: false)
        .orderBy(dateField, descending: true)
        .get()
        .then((value) =>
            value.docs.map((e) => CloudCustomerHistory.fromSnapshot(e)));
    if (result.isEmpty) {
      return 0;
    } else {
      
      return result.first.newUnit;
    }
  }

  Future<String> storeImage(String customerDocumentId, File file) async {
    try {
      final uploadTask = firebaseStorage
          .child(customerDocumentId)
          .child(currentMonthYearDate())
          .putFile(file);
      //deletes file from a year ago if present
      final yearAgoImgRef =
          firebaseStorage.child(customerDocumentId).child(pastMonthYearDate());
      yearAgoImgRef
          .getDownloadURL()
          .then((_) => yearAgoImgRef.delete(), onError: (e) => e);
      final snapshot = await uploadTask.whenComplete(() {});

      final urlDownload = await snapshot.ref.getDownloadURL();
      return urlDownload;
    } catch (e) {
      throw UnableToUploadImageException();
    }
  }

  Future<num> get getPrice => priceCollectionDoc.get().then(
        (DocumentSnapshot doc) {
          final price = doc.data() as Map<String, dynamic>;
          return price[pricePerUnitField] as num;
        },
        onError: (_) {
          throw CouldNotGetPriceException();
        },
      );

  Future<num> get getRoadLightPrice =>
      priceCollectionDoc.get().then((DocumentSnapshot doc) {
        final price = doc.data() as Map<String, dynamic>;
        dev.log(price[roadLightPriceField].toString());
        return price[roadLightPriceField] as num;
      }, onError: (_) => throw CouldNotGetPriceException());

  Future<num> get getHorsePowerPerUnitCost => priceCollectionDoc.get().then(
        (DocumentSnapshot doc) {
          final price = doc.data() as Map<String, dynamic>;
          return price[horsePowerPerUnitCostField] as num;
        },
        onError: (_) {
          throw CouldNotGetPriceException();
        },
      );

  Future<num> get getServiceCharge => priceCollectionDoc.get().then(
        (DocumentSnapshot doc) {
          final price = doc.data() as Map<String, dynamic>;
          // dev.log('1${price[pricePerUnitField].toString()}');
          // dev.log("2${price[serviceChargeField].toString()}");
          // dev.log("3${price[horsePowerPerUnitCostField].toString()}");
          // dev.log("4${price[roadLightPriceField].toString()}");
          return price[serviceChargeField] as num;
        },
        onError: (_) {
          throw CouldNotGetPriceException();
        },
      );

  // Future<void> setPrice(String newPrice, String token) async {
  //   num? parsedNewPrice = num.tryParse(newPrice);
  //   final serverToken = await getServerToken;
  //   if (token != serverToken) {
  //     throw UnAuthorizedPriceSetException();
  //   } else if (parsedNewPrice != null && parsedNewPrice != 0) {
  //     await priceCollectionDoc.update({pricePerUnitField: parsedNewPrice});
  //   } else {
  //     throw CouldNotSetPriceException();
  //   }
  // }

  Future<void> setPrice({
    required String newPrice,
    required String token,
    required String priceChangeField,
  }) async {
    try {
      num? parsedNewPrice = num.tryParse(newPrice);
      final serverToken = await getServerToken;
      if (token != serverToken) {
        throw UnAuthorizedPriceSetException();
      } else if (parsedNewPrice != null &&
          parsedNewPrice != 0) {
        await priceCollectionDoc
            .update({priceChangeField: parsedNewPrice});
      } else {
        throw CouldNotSetServiceChargeException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setServiceCharge(String newServiceCharge, String token) async {
    try {
      num? parsedNewServiceCharge = num.tryParse(newServiceCharge);
      final serverToken = await getServerToken;
      if (token != serverToken) {
        throw UnAuthorizedPriceSetException();
      } else if (parsedNewServiceCharge != null &&
          parsedNewServiceCharge != 0) {
        await priceCollectionDoc
            .update({serviceChargeField: parsedNewServiceCharge});
      } else {
        throw CouldNotSetServiceChargeException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> printReceipt({
    required CloudCustomer customer,
    required CloudCustomerHistory history,
  }) async {
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
            Unit Used: ${(history.newUnit - history.previousUnit)}
            Price Per Unit: ${history.priceAtm}
            Service Charge: ${history.serviceChargeAtm}
            Cost: ${(history.newUnit - history.previousUnit) * history.priceAtm + history.serviceChargeAtm}
            ${FirebaseAuth.instance.currentUser!.email}
    ''';
  }

  Future<num> calculateCost(CloudCustomer customer, num newReading) async {
    final price = await getPrice;
    final previusUnit = await getPreviousValidUnit(customer);
    final serviceCharge = await getServiceCharge;
    final meterMultiplier = customer.meterMultiplier;
    final roadLightPrice = await getRoadLightPrice;
    final horsePowerPerUnitCost = await getHorsePowerPerUnitCost;
    final horsePowerUnits = customer.horsePowerUnits;
    final hasRoadLight = customer.hasRoadLightCost ? 1 : 0;
    final result = price * (newReading - previusUnit) * meterMultiplier +
        horsePowerUnits * horsePowerPerUnitCost +
        serviceCharge +
        hasRoadLight * roadLightPrice;
    return result;
  }

  Future<void> submitElectricLog({
    required String comment,
    required num newReading,
    required bool flag,
    required String imageUrl,
    required CloudCustomer customer,
  }) async {
    try {
      final customerDetailDocRef =
          _customersDetailsCollection.doc(customer.documentId);
      final customerHistoryDocRef = FirebaseFirestore.instance
          .collection(
              '$customerDetailsCollection/${customer.documentId}/$historyCollection')
          .doc();
      FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          transaction.set(customerHistoryDocRef, {
            commentField: comment,
            //need update
            costField: await calculateCost(customer, newReading),
            dateField: DateTime.now().toString(),
            horsePowerPerUnitCostAtmField: await getHorsePowerPerUnitCost,
            horsePowerUnitsField: customer.horsePowerUnits,
            imageUrlField: imageUrl,
            inspectorField: FirebaseAuth.instance.currentUser!.email,
            meterMultiplierField: customer.meterMultiplier,
            newUnitField: newReading,
            previousUnitField: await getPreviousValidUnit(customer),
            priceAtmField: await getPrice,
            isPaidField: false,
            isVoidedField: false,
            serviceChargeField: await getServiceCharge,
          });
        },
      ).then((value) => dev.log("Document submitted successfully."),
          onError: (e) {
        dev.log(e.toString());
        throw UnableToUpdateException();
      });

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(customerDetailDocRef, {
          flagField: flag,
          lastUnitField: newReading,
        });
      }).then((value) => dev.log("Document submitted successfully."),
          onError: (e) => throw UnableToUpdateException());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resolveIssue({
    required CloudCustomer customer,
    required String comment,
  }) async {
    try {
      dev.log('message1');
      final customerDocRef =
          _customersDetailsCollection.doc(customer.documentId);
      dev.log('message2');
      final customerHistory = await getCustomerHistory(customer: customer);
      dev.log('message3');
      final customerHistoryRef = FirebaseFirestore.instance
          .collection(
              '$customerDetailsCollection/${customer.documentId}/$historyCollection')
          // ignore: unnecessary_string_interpolations
          .doc('${customerHistory.documentId}');
      dev.log('message4');
      //unflag customer
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(customerDocRef, {
          flagField: false,
        });
      }).then((value) => dev.log("Document submitted successfully."),
          onError: (e) {
        dev.log("1.");
        throw UnableToUpdateException();
      });
      dev.log('message5');
      //set an issue with a date. Only 1 issue resolved per month.
      //issue as Date, comment and reference to the history
      FirebaseFirestore.instance.runTransaction((transaction) async {
        FirebaseFirestore.instance
            .collection(
                '$customerDetailsCollection/${customer.documentId}/$issueCollection')
            .doc(DateTime.now().toString().substring(0, 7))
            .set({
          dateField: DateTime.now().toString(),
          commentField: comment,
          referenceField: customerHistoryRef,
        });
      }).then((value) => dev.log("Document submitted successfully."),
          onError: (e) {
        dev.log("2.");
        throw UnableToUpdateException();
      });
    } catch (e) {
      dev.log('message');
      throw UnableToUpdateException();
    }
  }

  Future<CloudCustomerHistory> getCustomerHistory(
      {required CloudCustomer customer}) async {
    final customerHistoryCollection = FirebaseFirestore.instance.collection(
        '$customerDetailsCollection/${customer.documentId}/$historyCollection');
    final result = await customerHistoryCollection
        .where(isVoidedField, isEqualTo: false)
        .orderBy(dateField, descending: true)
        .get()
        .then((value) =>
            value.docs.map((e) => CloudCustomerHistory.fromSnapshot(e)));
    return result.first;
  }

//problem
  Future<void> voidCurrentMonthHistory({
    required CloudCustomer customer,
  }) async {
    final customerHistoryCollection = FirebaseFirestore.instance.collection(
        '$customerDetailsCollection/${customer.documentId}/$historyCollection');
    await customerHistoryCollection
        .where(dateField,
            isGreaterThanOrEqualTo: DateTime.now().toString().substring(0, 7))
        .get()
        .then((response) async {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in response.docs) {
        final docRef = customerHistoryCollection.doc(doc.id);
        batch.update(docRef, {isVoidedField: true});
      }
      await batch.commit();
    });
  }

  Future<Iterable<CloudCustomer>> allFlaggedCustomer() async {
    return _customersDetailsCollection
        .where(flagField, isEqualTo: true)
        .get()
        .then((value) =>
            value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));
  }

  Future<Iterable<CloudCustomer>> searchFlaggedCustomer({
    required String userInput,
    required Iterable<CloudCustomer> customers,
  }) async {
    return customers.where((customer) =>
        (customer.bookId == userInput || customer.meterId == userInput));
  }

  Future<Iterable<CloudCustomerHistory>> getCustomerAllHistory(
      {required CloudCustomer customer}) async {
    final customerHistoryCollection = FirebaseFirestore.instance.collection(
        '$customerDetailsCollection/${customer.documentId}/$historyCollection');
    final result = await customerHistoryCollection
        .orderBy(dateField, descending: true)
        .get()
        .then((value) =>
            value.docs.map((doc) => CloudCustomerHistory.fromSnapshot(doc)));
    return result;
  }

  Future<Iterable<CloudCustomer>> getCustomer({
    // int? id,
    required String? bookId,
    required String? meterNumber,
  }) async {
    try {
      if (bookId != null) {
        return await _customersDetailsCollection
            .where(bookIdField, isEqualTo: bookId)
            .get()
            .then((value) =>
                value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));
      }
      if (meterNumber != null) {
        return await _customersDetailsCollection
            .where(meterIdField, isEqualTo: meterNumber)
            .get()
            .then((value) =>
                value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));
      }
      throw CouldNotGetCustomerException();
    } catch (e) {
      throw CouldNotGetCustomerException();
    }
  }

  Future<void> createUser({
    required String name,
    required String address,
    required String bookId,
    required String meterId,
    required num meterReading,
    required num meterMultiplier,
    required num horsePowerUnits,
    required bool hasRoadLight,
  }) async {
    final newCustomerCollectionRef = _customersDetailsCollection.doc();
    await newCustomerCollectionRef.set({
      nameField: name,
      addressField: address,
      meterIdField: meterId,
      bookIdField: bookId,
      lastUnitField: meterReading,
      flagField: false,
      hasRoadLightCostField: hasRoadLight,
      meterMultiplierField: meterMultiplier,
      horsePowerUnitsField: horsePowerUnits,
      adderField: 0,
    });
    final customerHistoryDocRef = FirebaseFirestore.instance
        .collection(
            '$customerDetailsCollection/${newCustomerCollectionRef.id}/$historyCollection')
        .doc();
    FirebaseFirestore.instance.runTransaction(
      (transaction) async {
        transaction.set(customerHistoryDocRef, {
          previousUnitField: meterReading,
          newUnitField: meterReading,
          priceAtmField: await getPrice,
          serviceChargeField: await getServiceCharge,
          isVoidedField: false,
          dateField: pastMonthYearDate(),
          costField: 0,
          inspectorField: '',
          meterMultiplierField: meterMultiplier,
          horsePowerUnitsField: horsePowerUnits,
          horsePowerPerUnitCostAtmField: await getHorsePowerPerUnitCost,
          commentField: '',
          isPaidField: true,
          imageUrlField:
              'https://firebasestorage.googleapis.com/v0/b/electricityplus-a6572.appspot.com/o/newUser%2Fsoil.jpg?alt=media&token=93cdbd32-72a3-4992-a134-226d465c340f',
        });
      },
    ).then((value) => dev.log("Document submitted successfully."),
        onError: (e) => throw UnableToUpdateException());
  }

  Future<Iterable<CloudCustomer>> allCustomer() =>
      _customersDetailsCollection.get().then(
          (value) => value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
