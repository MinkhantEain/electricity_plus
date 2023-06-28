import 'dart:convert';
import 'dart:io';

import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/cloud_customer_history.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/others/excel_production.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:electricity_plus/services/others/town.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev show log;

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseCloudStorage {
  final firebaseFirestoreInstance = FirebaseFirestore.instance;

  final priceCollectionDoc =
      FirebaseFirestore.instance.collection(priceCollection).doc(priceDoc);

  final firebaseStorage = FirebaseStorage.instance.ref();

  Future<bool> isAdminPersonnel(String uid) async {
    return FirebaseFirestore.instance
        .collection('AdminPersonnelList')
        .doc(uid)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.data() != null) {
        final snapshot = doc.data() as Map<String, dynamic>;
        return snapshot['AdminPage'];
      } else {
        return false;
      }
    }, onError: (_) => false);
  }

  Future<String> get getServerToken => FirebaseFirestore.instance
          .collection('Admin')
          .doc('Details')
          .get()
          .then((DocumentSnapshot doc) {
        final snapshot = doc.data() as Map<String, dynamic>;
        return snapshot['Password'];
      }, onError: (_) => throw CouldNotGetPasswordException());

  Future<num> getPreviousValidUnit(CloudCustomer customer) async {
    final town = AppDocumentData.getTownName();
    final customerHistoryCollection = firebaseFirestoreInstance.collection(
        '$town$customerDetailsCollection/${customer.documentId}/$historyCollection');
    final result = await customerHistoryCollection
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

  ///Stores the image in FirebaseStorage with customer's document Id as the folder name
  ///and the month-year date of the month the photo is taken as the name of the image.
  ///This is to reduce storage and to have only one actual image per month and the rest are unnecessary.
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

  ///return the price
  Future<num> get getPrice => priceCollectionDoc.get().then(
        (DocumentSnapshot doc) {
          final price = doc.data() as Map<String, dynamic>;
          return price[pricePerUnitField] as num;
        },
        onError: (_) {
          throw CouldNotGetPriceException();
        },
      );

  ///return road light price
  Future<num> get getRoadLightPrice =>
      priceCollectionDoc.get().then((DocumentSnapshot doc) {
        final price = doc.data() as Map<String, dynamic>;
        dev.log(price[roadLightPriceField].toString());
        return price[roadLightPriceField] as num;
      }, onError: (_) => throw CouldNotGetPriceException());

  ///return the unit cost of the horse power
  Future<num> get getHorsePowerPerUnitCost => priceCollectionDoc.get().then(
        (DocumentSnapshot doc) {
          final price = doc.data() as Map<String, dynamic>;
          return price[horsePowerPerUnitCostField] as num;
        },
        onError: (_) {
          throw CouldNotGetPriceException();
        },
      );

  ///return the service charge
  Future<num> get getServiceCharge => priceCollectionDoc.get().then(
        (DocumentSnapshot doc) {
          final price = doc.data() as Map<String, dynamic>;
          return price[serviceChargeField] as num;
        },
        onError: (_) {
          throw CouldNotGetPriceException();
        },
      );

  Future<void> setPrice({
    required String newPrice,
    required String token,
    required String priceChangeField,
  }) async {
    try {
      if (!isIntInput(newPrice)) {
        throw CouldNotSetPriceException();
      }
      num? parsedNewPrice = num.tryParse(newPrice);
      final serverToken = await getServerToken;
      if (token != serverToken) {
        throw UnAuthorizedPriceSetException();
      } else if (parsedNewPrice != null && parsedNewPrice != 0) {
        await priceCollectionDoc.update({priceChangeField: parsedNewPrice});
      } else {
        throw CouldNotSetPriceException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyPassword(String token) async {
    return token == await getServerToken;
  }


  Future<List<LineText>> printBill({
    required CloudCustomer customer,
    required CloudCustomerHistory history,
  }) async {
    Map<String, String?> map = {
      'documentId': history.documentId,
      dateField: history.date,
      bookIdField: customer.bookId,
      nameField: customer.name,
      addressField: customer.address,
      meterIdField: customer.meterId,
      previousUnitField: history.previousUnit.toString(),
      newUnitField: history.newUnit.toString(),
      serviceChargeAtmField: history.serviceChargeAtm.toString(),
      horsePowerUnitsField: customer.horsePowerUnits == 0
          ? null
          : (history.horsePowerUnits * history.horsePowerPerUnitCostAtm)
              .toString(),
      roadLightPriceField:
          customer.hasRoadLightCost ? history.roadLightPrice.toString() : null,
      meterMultiplierField: customer.meterMultiplier == 1
          ? null
          : customer.meterMultiplier.toString(),
      costField: (await calculateCost(customer, history.newUnit)).toString(),
    };
    dev.log("print receipt is executed");
    return (await printBillHelper(map));
    // return '''
    //         Receipt ID: ${history.documentId}
    //         -Details-
    //         Date: ${history.date}
    //         Name: ${customer.name}
    //         Meter ID: ${customer.meterId}
    //         Address: ${customer.address}
    //         Previous Reading: ${history.previousUnit}
    //         New Reading: ${history.newUnit}
    //         Unit Used: ${(history.newUnit - history.previousUnit)}
    //         Price Per Unit: ${history.priceAtm}
    //         Service Charge: ${history.serviceChargeAtm}
    //         Cost: ${(history.newUnit - history.previousUnit) * history.priceAtm + history.serviceChargeAtm}
    //         ${FirebaseAuth.instance.currentUser!.email}
    // ''';
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
      final town = await AppDocumentData.getTownName();
      final customerDetailDocRef = firebaseFirestoreInstance
          .collection('$town$customerDetailsCollection')
          .doc(customer.documentId);
      final customerHistoryDocRef = FirebaseFirestore.instance
          .collection(
              '$town$customerDetailsCollection/${customer.documentId}/$historyCollection')
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
            roadLightPriceField: await getRoadLightPrice,
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
          lastHistoryField: customerHistoryDocRef,
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
      final town = await AppDocumentData.getTownName();
      final customerDocRef = firebaseFirestoreInstance
          .collection('$town$customerDetailsCollection')
          .doc(customer.documentId);
      final customerHistory = await getCustomerHistory(customer: customer);
      final customerHistoryRef = FirebaseFirestore.instance
          .collection(
              '$town$customerDetailsCollection/${customer.documentId}/$historyCollection')
          // ignore: unnecessary_string_interpolations
          .doc('${customerHistory.documentId}');
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
      //set an issue with a date..
      //issue as Date, comment and reference to the history
      FirebaseFirestore.instance.runTransaction((transaction) async {
        FirebaseFirestore.instance
            .collection(
                '$town$customerDetailsCollection/${customer.documentId}/$issueCollection')
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

  ///get all the towns from firebase
  ///if there are no town, exception will not be thrown as it will return empty iterable.
  Future<Iterable<Town>> getAllTown() async {
    return await FirebaseFirestore.instance
        .collection(townCollection)
        .get()
        .then((value) => value.docs.map((doc) => Town.fromSnapshot(doc)));
  }

  /// add town to firebase
  /// each town is a document in firebase
  Future<void> addTown(String townName) async {
    FirebaseFirestore.instance.collection(townCollection).doc(townName).set({});
  }

  ///delete town from firebase
  ///each town is a document in firebase
  Future<void> deleteTown(String townName) async {
    FirebaseFirestore.instance
        .collection(townCollection)
        .doc(townName)
        .delete();
  }

  Future<CloudCustomerHistory> getCustomerHistory(
      {required CloudCustomer customer}) async {
    final town = await AppDocumentData.getTownName();
    final customerHistoryCollection = FirebaseFirestore.instance.collection(
        '$town$customerDetailsCollection/${customer.documentId}/$historyCollection');
    final result = await customerHistoryCollection
        .where(isVoidedField, isEqualTo: false)
        .orderBy(dateField, descending: true)
        .get()
        .then((value) =>
            value.docs.map((e) => CloudCustomerHistory.fromSnapshot(e)));
    return result.first;
  }

//problem
  Future<void> voidCurrentMonthLastHistory({
    required CloudCustomer customer,
  }) async {
    final previousHistory = await customer.lastHistory.get();
    if (DateTime.parse(previousHistory[dateField]).isBefore(DateTime.now())) {
      customer.lastHistory.update({isVoidedField: true});
    }
    // final town = AppDocumentData.getTownName();
    // final customerHistoryCollection = FirebaseFirestore.instance.collection(
    //     '$town$customerDetailsCollection/${customer.documentId}/$historyCollection');
    // await customerHistoryCollection
    //     .where(dateField,
    //         isGreaterThanOrEqualTo: DateTime.now().toString().substring(0, 7))
    //     .get()
    //     .then((response) async {
    //   WriteBatch batch = FirebaseFirestore.instance.batch();
    //   for (QueryDocumentSnapshot<Map<String, dynamic>> doc in response.docs) {
    //     final docRef = customerHistoryCollection.doc(doc.id);
    //     dev.log(doc.id);
    //     batch.update(docRef, {isVoidedField: true});
    //   }
    //   await batch.commit();
    //   dev.log('batch updated');
    // });
  }

  Future<Iterable<CloudCustomer>> allFlaggedCustomer() async {
    final town = await AppDocumentData.getTownName();
    return await firebaseFirestoreInstance
        .collection('$town$customerDetailsCollection')
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
    final town = await AppDocumentData.getTownName();
    final customerHistoryCollection = FirebaseFirestore.instance.collection(
        '$town$customerDetailsCollection/${customer.documentId}/$historyCollection');
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
    final town = await AppDocumentData.getTownName();
    final detailsCollection =
        firebaseFirestoreInstance.collection('$town$customerDetailsCollection');
    try {
      if (bookId != null) {
        return await (detailsCollection)
            .where(bookIdField, isEqualTo: bookId)
            .get()
            .then((value) =>
                value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));
      }
      if (meterNumber != null) {
        return await detailsCollection
            .where(meterIdField, isEqualTo: meterNumber)
            .get()
            .then((value) =>
                value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));
      }
      return [];
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
    try {
      final town = await AppDocumentData.getTownName();
      final detailsCollection = firebaseFirestoreInstance
          .collection('$town$customerDetailsCollection');
      final newCustomerDocRef = detailsCollection.doc();
      final customerHistoryDocRef = FirebaseFirestore.instance
          .collection(
              '$town$customerDetailsCollection/${newCustomerDocRef.id}/$historyCollection')
          .doc();
      await newCustomerDocRef.set({
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
        lastHistoryField: customerHistoryDocRef,
      });

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
            roadLightPriceField: hasRoadLight ? await getRoadLightPrice : 0,
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
          onError: (e) {
        throw CouldNotCreateCustomerException();
      });
    } on Exception {
      rethrow;
    }
  }

  Future<Iterable<CloudCustomer>> allCustomer() async {
    final town = await AppDocumentData.getTownName();
    return await firebaseFirestoreInstance
        .collection('$town$customerDetailsCollection')
        .orderBy(bookIdField)
        .get()
        .then((value) =>
            value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));
  }

  Future<void> importData(PlatformFile platformFile) async {
    final file = File(platformFile.path!);
    final lines =
        file.openRead().transform(utf8.decoder).transform(const LineSplitter());
    await for (var line in lines) {
      final splitExpression = RegExp(",(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))");
      final splittedLine = line.split(splitExpression);
      if (isIntInput(splittedLine[0].trim())) {
        try {
          final name = splittedLine[3];
          final address = splittedLine[7];
          final bookId = splittedLine[6];
          final meterId = splittedLine[2];
          final meterReading = num.parse(splittedLine[11].trim());
          final meterMultiplier = splittedLine[12].trim().isEmpty
              ? 1
              : num.parse(splittedLine[12].trim());
          final horsePowerUnits = num.parse(splittedLine[18].trim());
          final hasRoadLight =
              num.parse(splittedLine[16].trim()) == 0 ? false : true;
          await createUser(
            name: name,
            address: address,
            bookId: bookId,
            meterId: meterId,
            meterReading: meterReading,
            meterMultiplier: meterMultiplier,
            horsePowerUnits: horsePowerUnits,
            hasRoadLight: hasRoadLight,
          );
        } catch (e) {
          dev.log(splittedLine.toString());

          dev.log((splittedLine[12].trim().isEmpty
                  ? 0
                  : num.parse(splittedLine[12].trim()))
              .toString());
          dev.log(num.parse(splittedLine[18].trim()).toString());
          dev.log((num.parse(splittedLine[16].trim()) == 0 ? false : true)
              .toString());
          dev.log(num.parse(splittedLine[11].trim()).toString());
        }
      }
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
