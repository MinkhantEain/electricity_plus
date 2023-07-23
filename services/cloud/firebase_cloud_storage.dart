import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/models/cloud_flag.dart';
import 'package:electricity_plus/services/models/cloud_price_doc.dart';
import 'package:electricity_plus/services/models/cloud_receipt_model.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/models/exchange_model.dart';
import 'package:electricity_plus/services/models/users.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:electricity_plus/services/others/town.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev show log;

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseCloudStorage {
  final firebaseFirestoreInstance = FirebaseFirestore.instance;

  final firebaseStorage = FirebaseStorage.instance.ref();

  Future<Iterable<CloudCustomerHistory>> getStaffHistorySpecificDate(
      {required Staff staff, required String date}) async {
    final town = await AppDocumentData.getTownName();
    return firebaseFirestoreInstance
        .collectionGroup(historyCollection)
        .where(inspectorUidField, isEqualTo: staff.uid)
        .where(townField, isEqualTo: town)
        .where(dateField, isGreaterThanOrEqualTo: date)
        .where(dateField,
            isLessThanOrEqualTo: DateTime(
              int.parse(date.substring(0, 4)),
              int.parse(date.substring(5, 7)),
              int.parse(date.substring(8)) + 1,
            ).toString())
        .where(isVoidedField, isEqualTo: false)
        .get()
        .then((value) =>
            value.docs.map((e) => CloudCustomerHistory.fromSnapshot(e)));
  }

  Future<void> editCustomerDetails(
      {required CloudCustomer updatedCustomer}) async {
    final town = await AppDocumentData.getTownName();
    setDoc(
        document: FirebaseFirestore.instance.doc(
            '$town$customerDetailsCollection/${updatedCustomer.documentId}'),
        dataFieldMap: updatedCustomer.dataFieldMap());
  }

  Future<Iterable<CloudCustomerHistory>> getAllHistorySpecificDate(
      {required String date}) async {
    final town = await AppDocumentData.getTownName();
    return firebaseFirestoreInstance
        .collectionGroup(historyCollection)
        .where(townField, isEqualTo: town)
        .where(dateField, isGreaterThanOrEqualTo: date)
        .where(dateField,
            isLessThanOrEqualTo: DateTime(
              int.parse(date.substring(0, 4)),
              int.parse(date.substring(5, 7)),
              int.parse(date.substring(8)) + 1,
            ).toString())
        .where(isVoidedField, isEqualTo: false)
        .get()
        .then((value) =>
            value.docs.map((e) => CloudCustomerHistory.fromSnapshot(e)));
  }

  Future<Iterable<CloudReceipt>> getStaffReceiptSpecificDate(
      {required Staff staff, required String date}) async {
    final town = await AppDocumentData.getTownName();
    dev.log(date);

    return firebaseFirestoreInstance
        .collectionGroup(receiptCollection)
        .where(collectorUidField, isEqualTo: staff.uid)
        .where(townNameField, isEqualTo: town)
        .where(transactionDateField, isGreaterThanOrEqualTo: date)
        .where(transactionDateField,
            isLessThanOrEqualTo: DateTime(
              int.parse(date.substring(0, 4)),
              int.parse(date.substring(5, 7)),
              int.parse(date.substring(8)) + 1,
            ).toString())
        .get()
        .then((value) => value.docs.map((e) => CloudReceipt.fromSnapshot(e)));
  }

  Future<Iterable<CloudReceipt>> getAllReceiptSpecificDate(
      {required String date}) async {
    final town = await AppDocumentData.getTownName();
    return firebaseFirestoreInstance
        .collectionGroup(receiptCollection)
        .where(townNameField, isEqualTo: town)
        .where(transactionDateField, isGreaterThanOrEqualTo: date)
        .where(transactionDateField,
            isLessThanOrEqualTo: DateTime(
              int.parse(date.substring(0, 4)),
              int.parse(date.substring(5, 7)),
              int.parse(date.substring(8)) + 1,
            ).toString())
        .get()
        .then((value) => value.docs.map((e) => CloudReceipt.fromSnapshot(e)));
  }

  Future<Iterable<Staff>> getAllActiveStaff() async {
    final town = await AppDocumentData.getTownName();
    return FirebaseFirestore.instance
        .collection('$town$staffCollection')
        .where(userTypeField, isNotEqualTo: undecidedType)
        .get()
        .then((value) => value.docs.map((e) => Staff.fromSnapshot(e)));
  }

  Future<Iterable<Staff>> getAllSuspendedStaff() async {
    final town = await AppDocumentData.getTownName();
    return FirebaseFirestore.instance
        .collection('$town$staffCollection')
        .where(userTypeField, isEqualTo: undecidedType)
        .get()
        .then((value) => value.docs.map((e) => Staff.fromSnapshot(e)));
  }

  Future<void> suspendStaff(Staff staff) async {
    final town = await AppDocumentData.getTownName();
    final staffDocRef =
        FirebaseFirestore.instance.doc('$town$staffCollection/${staff.uid}');
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(staffDocRef, {userTypeField: undecidedType});
    });
  }

  Future<void> activateUser(Staff staff, String userType) async {
    final town = await AppDocumentData.getTownName();
    final staffDocRef =
        FirebaseFirestore.instance.doc('$town$staffCollection/${staff.uid}');
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(staffDocRef, {
        userTypeField: userType,
        isStaffField: true,
      });
    });
  }

  Future<void> deleteStaff({required Staff staff}) async {
    final town = await AppDocumentData.getTownName();
    final currentUserCredentials = await AppDocumentData.getUserDetails();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: staff.email,
      password: staff.password,
    );
    await FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: currentUserCredentials.email,
      password: currentUserCredentials.password,
    );
    FirebaseFirestore.instance
        .doc('$town$staffCollection/${staff.uid}')
        .delete();
  }

  Future<num> getTownCount() async {
    return FirebaseFirestore.instance
        .doc('$townCountCollection/$townCountDoc')
        .get()
        .then((value) => value.data()![townCountField]);
  }

  Future<void> setTownCount(num newCount) async {
    final townCountDocRef =
        FirebaseFirestore.instance.doc('$townCountCollection/$townCountDoc');
    setDoc(document: townCountDocRef, dataFieldMap: {townCountField: newCount});
  }

  Future<Staff?> getCurrentUser(String uid) async {
    final town = await AppDocumentData.getTownName();

    return FirebaseFirestore.instance
        .doc('$town$staffCollection/$uid')
        .get()
        .then((value) => Staff.fromDocSnapshot(value))
        .onError((error, stackTrace) => throw Exception());
  }

  Future<void> createStaff(Staff staff) async {
    final town = await AppDocumentData.getTownName();
    final staffDocRef = FirebaseFirestore.instance
        .collection('$town$staffCollection')
        .doc(staff.uid);
    await setDoc(document: staffDocRef, dataFieldMap: staff.dataFieldMap());
  }

  Future<String> get getServerToken => FirebaseFirestore.instance
          .collection('Admin')
          .doc('Details')
          .get()
          .then((DocumentSnapshot doc) {
        final snapshot = doc.data() as Map<String, dynamic>;
        return snapshot['Password'];
      }, onError: (_) => throw CouldNotGetPasswordException());

  ///Stores the image in FirebaseStorage with customer's document Id as the folder name
  ///and the month-year date of the month the photo is taken as the name of the image.
  ///This is to reduce storage and to have only one actual image per month and the rest are unnecessary.
  Future<String> storeImage(String customerDocumentId, File file,
      {String fileName = ''}) async {
    try {
      final town = await AppDocumentData.getTownName();
      final uploadTask = firebaseStorage
          .child(town)
          .child(customerDocumentId)
          .child(currentMonthYearDate() + fileName)
          .putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});

      final urlDownload = await snapshot.ref.getDownloadURL();
      return urlDownload;
    } catch (e) {
      throw UnableToUploadImageException();
    }
  }

  Future<Uint8List?> getImage(String imageUrl) {
    return FirebaseStorage.instance.refFromURL(imageUrl).getData();
  }

  ///return the price
  Future<num> getPrice() async {
    return await getPriceFromField(specificPriceField: pricePerUnitField);
  }

  ///return road light price
  Future<num> getRoadLightPrice() async {
    return await getPriceFromField(specificPriceField: roadLightPriceField);
  }

  ///return the unit cost of the horse power
  Future<num> getHorsePowerPerUnitCost() async {
    return await getPriceFromField(
        specificPriceField: horsePowerPerUnitCostField);
  }

  ///get price from field in price doc.
  Future<num> getPriceFromField({required String specificPriceField}) async {
    final town = await AppDocumentData.getTownName();
    return FirebaseFirestore.instance
        .doc('$town$priceCollection/$priceDoc')
        .get()
        .then(
      (DocumentSnapshot doc) {
        final price = doc.data() as Map<String, dynamic>;
        return price[specificPriceField] as num;
      },
      onError: (_) {
        throw CouldNotGetPriceException();
      },
    );
  }

  Future<CloudPriceDoc> getAllPrices() async {
    final town = await AppDocumentData.getTownName();
    return FirebaseFirestore.instance
        .doc('$town$priceCollection/$priceDoc')
        .get()
        .then((value) => CloudPriceDoc.fromDocSnapshot(value))
        .onError((error, stackTrace) => throw NoSuchDocumentException());
  }

  ///return the service charge
  Future<num> getServiceCharge() async {
    return await getPriceFromField(specificPriceField: serviceChargeField);
  }

  Future<void> setPrice({
    required String newPrice,
    required String token,
    required String priceChangeField,
  }) async {
    final town = await AppDocumentData.getTownName();
    try {
      if (!isIntInput(newPrice)) {
        throw CouldNotSetPriceException();
      }
      num? parsedNewPrice = num.tryParse(newPrice);
      final serverToken = await getServerToken;
      if (token != serverToken) {
        throw UnAuthorizedPriceSetException();
      } else if (parsedNewPrice != null && parsedNewPrice != 0) {
        await FirebaseFirestore.instance
            .doc('$town$priceCollection/$priceDoc')
            .update({priceChangeField: parsedNewPrice});
      } else {
        throw CouldNotSetPriceException();
      }
    } catch (e) {
      rethrow;
    }
  }

  ///used only when data is imported at the start,
  ///likely never be used again.
  Future<void> initialisePrices() async {
    final town = await AppDocumentData.getTownName();
    await FirebaseFirestore.instance
        .doc('$town$priceCollection/$priceDoc')
        .set({
      pricePerUnitField: 990,
      horsePowerPerUnitCostField: 200,
      roadLightPriceField: 200,
      serviceChargeField: 500,
    });
  }

  Future<bool> verifyPassword(String token) async {
    return token == await getServerToken;
  }

  // Future<String> printBill({
  //   required CloudCustomer customer,
  //   required CloudCustomerHistory history,
  // }) async {
  //   return '''
  //           Receipt ID: ${history.documentId}
  //           -Details-
  //           Date: ${history.date}
  //           Name: ${customer.name}
  //           Meter ID: ${customer.meterId}
  //           Address: ${customer.address}
  //           Previous Reading: ${history.previousUnit}
  //           New Reading: ${history.newUnit}
  //           Unit Used: ${(history.newUnit - history.previousUnit)}
  //           Price Per Unit: ${history.priceAtm}
  //           Service Charge: ${history.serviceChargeAtm}
  //           Cost: ${(history.newUnit - history.previousUnit) * history.priceAtm + history.serviceChargeAtm}
  //           ${FirebaseAuth.instance.currentUser!.email}
  //   ''';
  // }

  Future<num> calculateCost(CloudCustomer customer, num newReading) async {
    final prices = await getAllPrices();
    final price = prices.pricePerUnit;
    final previousUnit = await getPreviousValidUnit(customer);
    final serviceCharge = prices.serviceCharge;
    final meterMultiplier = customer.meterMultiplier;
    final roadLightPrice = prices.roadLightPrice;
    final horsePowerPerUnitCost = prices.horsePowerPerUnitCost;
    final horsePowerUnits = customer.horsePowerUnits;
    final hasRoadLight = customer.hasRoadLightCost ? 1 : 0;
    final calculatedHorsePowerCost = (newReading - previousUnit) == 0
        ? 0
        : horsePowerUnits * horsePowerPerUnitCost;
    final result = price * (newReading - previousUnit) * meterMultiplier +
        calculatedHorsePowerCost +
        serviceCharge +
        hasRoadLight * roadLightPrice;
    return result;
  }

  Future<void> submitFlagReport({
    required CloudCustomer customer,
    required String comment,
    required String imageUrl,
    required String inspector,
  }) async {
    final town = await AppDocumentData.getTownName();
    final flag = CloudFlag(
      date: DateTime.now().toString(),
      comment: comment,
      town: town,
      documentId: DateTime.now().toString().substring(0, 7),
      imageUrl: imageUrl,
      inspector: inspector,
      isResolved: false,
    );

    final flagDocRef = FirebaseFirestore.instance.doc(
        '$town$customerDetailsCollection/${customer.documentId}/$flagCollection/${flag.documentId}');
    //creates a flag collection
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(flagDocRef, {
        dateField: flag.date,
        commentField: flag.comment,
        imageUrlField: flag.imageUrl,
        townField: town,
        inspectorField: flag.inspector,
        isResolvedField: flag.isResolved,
      });
    });

    //Flag the customer
    final customerDocRef = FirebaseFirestore.instance
        .doc('$town$customerDetailsCollection/${customer.documentId}');
    firebaseFirestoreInstance.runTransaction((transaction) async {
      transaction.update(customerDocRef, {
        flagField: true,
        lastReadDateField: previousMonthYearDateNumericFormat()
      });
    });
  }

  ///Get the previous valid unit a.k.a from the latest previous month
  Future<num> getPreviousValidUnit(CloudCustomer customer) async {
    final town = await AppDocumentData.getTownName();
    final customerHistoryCollection = firebaseFirestoreInstance.collection(
        '$town$customerDetailsCollection/${customer.documentId}/$historyCollection');
    try {
      dev.log('d');
      final result = await customerHistoryCollection
          .where(dateField,
              isLessThanOrEqualTo: DateTime.now().toString().substring(0, 7))
          .where(isVoidedField, isEqualTo: false)
          .orderBy(dateField, descending: true)
          .limit(1)
          .get()
          .then(
            (value) => value.docs.first,
            onError: (error) => throw QueryFailsException(),
          );
      dev.log('e');
      return result[newUnitField];
    } on QueryFailsException {
      return 0;
    }
  }

  Future<Iterable<CloudCustomerHistory>> getCustomerHistoryByMonth(
      {String? givenDate}) async {
    String date = givenDate ?? DateTime.now().toString().substring(0, 7);
    final town = await AppDocumentData.getTownName();
    return firebaseFirestoreInstance
        .collectionGroup(historyCollection)
        .where(dateField, isGreaterThanOrEqualTo: date)
        .where(dateField, isLessThan: '$date-32')
        .where(isVoidedField, isEqualTo: false)
        .where(townField, isEqualTo: town)
        .get()
        .then((value) =>
            value.docs.map((e) => CloudCustomerHistory.fromSnapshot(e)));
  }

  Future<Iterable<CloudExchangeHistory>> getCustomerExchangeHistoryByMonth(
      {String? givenDate}) async {
    String date = givenDate ?? DateTime.now().toString().substring(0, 7);
    final town = await AppDocumentData.getTownName();
    return firebaseFirestoreInstance
        .collectionGroup(exchangeHistoryCollection)
        .where(dateField, isGreaterThanOrEqualTo: date)
        .where(dateField, isLessThan: '$date-32')
        .where(townField, isEqualTo: town)
        .get()
        .then((value) =>
            value.docs.map((e) => CloudExchangeHistory.fromSnapshot(e)));
  }

  ///gets the latest valid history of customer
  Future<CloudCustomerHistory> getCustomerHistory(
      {required CloudCustomer customer}) async {
    final lastHistorySnapshot = await customer.lastHistory.get();
    return CloudCustomerHistory.fromDocSnapshot(lastHistorySnapshot);
  }

  //scan qrCode to get customer history
  Future<CloudCustomerHistory> getCusomerHistoryFromQrCode(
      List<String> qrCodeData) async {
    final town = await AppDocumentData.getTownName();
    return await FirebaseFirestore.instance
        .doc(
            '$town$customerDetailsCollection/${qrCodeData[0]}/$historyCollection/${qrCodeData[1]}')
        .get()
        .then((value) => CloudCustomerHistory.fromDocSnapshot(value))
        .onError((error, stackTrace) {
      throw NoSuchDocumentException();
    });
  }

  ///void the last history if it is within this month.
  Future<num> voidCurrentMonthLastHistory({
    required CloudCustomer customer,
  }) async {
    final previousHistory = await customer.lastHistory.get();
    final previousHistoryDate = previousHistory[dateField];
    if (isWithinMonth(previousHistoryDate) && !previousHistory[isVoidedField]) {
      final town = await AppDocumentData.getTownName();
      customer.lastHistory.update({isVoidedField: true});
      if (!previousHistory[isPaidField]) {
        final debt = customer.debt -
            (previousHistory[costField] - previousHistory[paidAmount]);
        await FirebaseFirestore.instance
            .doc('$town$customerDetailsCollection/${customer.documentId}')
            .update({
          debtField: debt,
        });
        return (previousHistory[costField] - previousHistory[paidAmount]);
      } else {
        return 0;
      }
    } else {
      return 0;
    }
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

  Future<CloudCustomerHistory> submitElectricLog({
    required String comment,
    required num newReading,
    required String imageUrl,
    required CloudCustomer customer,
    required num previousReading,
  }) async {
    CloudCustomerHistory history;
    try {
      final town = await AppDocumentData.getTownName();
      final customerDocRef = FirebaseFirestore.instance
          .doc('$town$customerDetailsCollection/${customer.documentId}');
      final customerHistoryDocRef = FirebaseFirestore.instance
          .collection(
              '$town$customerDetailsCollection/${customer.documentId}/$historyCollection')
          .doc();
      final batch = FirebaseFirestore.instance.batch();
      final prices = await getAllPrices();
      history = CloudCustomerHistory(
          documentId: customerHistoryDocRef.id,
          previousUnit: previousReading,
          newUnit: newReading,
          town: town,
          name: customer.name,
          bookId: customer.bookId,
          priceAtm: prices.pricePerUnit,
          cost: await calculateCost(customer, newReading),
          date: DateTime.now().toString(),
          imageUrl: imageUrl,
          comment: comment,
          isPaid: false,
          isVoided: false,
          paidAmount: 0,
          meterAllowance: 0,
          inspector: FirebaseAuth.instance.currentUser!.displayName!,
          inspectorUid: FirebaseAuth.instance.currentUser!.uid,
          serviceChargeAtm: prices.serviceCharge,
          horsePowerPerUnitCostAtm: prices.horsePowerPerUnitCost,
          horsePowerUnits: customer.horsePowerUnits,
          meterMultiplier: customer.meterMultiplier,
          roadLightPrice: prices.roadLightPrice);

      //update the last history field and debt in customer
      final debt = (await customerDocRef.get())[debtField] + history.cost;
      batch.update(customerDocRef, {
        lastHistoryField: customerHistoryDocRef,
        debtField: debt,
        lastReadDateField: DateTime.now().toString()
      });

      //creates a new history document
      batch.set(customerHistoryDocRef, history.dataFieldMap());

      batch.commit();
    } catch (e) {
      rethrow;
    }
    return history;
  }

  Future<Iterable<CloudCustomerHistory>> getRecentBillHistory({
    required CloudCustomer customer,
    String? upperDateThreshold,
  }) async {
    final town = await AppDocumentData.getTownName();
    upperDateThreshold = upperDateThreshold ?? customer.lastReadDate;
    return await FirebaseFirestore.instance
        .collection(
            '$town$customerDetailsCollection/${customer.documentId}/$historyCollection')
        .where(isVoidedField, isEqualTo: false)
        .where(dateField, isLessThanOrEqualTo: upperDateThreshold)
        .orderBy(dateField, descending: true)
        .limit(6)
        .get()
        .then((value) =>
            value.docs.map((e) => CloudCustomerHistory.fromSnapshot(e)));
  }

  Future<Iterable<CloudCustomerHistory>> getUnpaidBill(
      {required CloudCustomer customer}) async {
    final town = await AppDocumentData.getTownName();
    return await FirebaseFirestore.instance
        .collection(
            '$town$customerDetailsCollection/${customer.documentId}/$historyCollection')
        .where(isPaidField, isEqualTo: false)
        .where(isVoidedField, isEqualTo: false)
        .get()
        .then((value) =>
            value.docs.map((doc) => CloudCustomerHistory.fromSnapshot(doc)));
  }

  Future<void> resolveRedFlag({
    required CloudCustomer customer,
    required String comment,
  }) async {
    try {
      final town = await AppDocumentData.getTownName();
      final customerDocRef = firebaseFirestoreInstance
          .collection('$town$customerDetailsCollection')
          .doc(customer.documentId);
      final flag = await getFlaggedIssue(customer: customer);
      final flagDocRef = FirebaseFirestore.instance.doc(
          '$town$customerDetailsCollection/${customer.documentId}/$flagCollection/${flag.documentId}');
      //unflag customer
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(customerDocRef, {
          flagField: false,
        });
      }).then((value) => dev.log("Document submitted successfully."),
          onError: (e) {
        dev.log("1.");
        throw UnableToUpdateCustomerDocFlagException();
      });
      //set an issue with a date..
      //issue as Date, comment and reference to the history
      FirebaseFirestore.instance.runTransaction((transaction) async {
        final issueDocRef = FirebaseFirestore.instance
            .collection(
                '$town$customerDetailsCollection/${customer.documentId}/$resolveCollection')
            .doc(DateTime.now().toString().substring(0, 7));
        transaction.set(issueDocRef, {
          dateField: DateTime.now().toString(),
          commentField: comment,
          referenceField: flagDocRef,
          inspectorField: FirebaseAuth.instance.currentUser!.displayName!
        });
      }).then((value) => dev.log("Document submitted successfully."),
          onError: (e) {
        dev.log("2.");
        throw UnableToCreateResolveDocException();
      });
    } catch (e) {
      rethrow;
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
    if (townName.isEmpty) {
      throw InvalidTownNameException();
    }
    FirebaseFirestore.instance.collection(townCollection).doc(townName).set({});
  }

  ///delete town from firebase
  ///each town is a document in firebase
  Future<void> deleteTown(String townName) async {
    await FirebaseFirestore.instance
        .collection(townCollection)
        .doc(townName)
        .delete();
  }

  Future<Iterable<CloudCustomer>> allInDebtCustomer() async {
    final town = await AppDocumentData.getTownName();
    return await FirebaseFirestore.instance
        .collection('$town$customerDetailsCollection')
        .where(debtField, isNotEqualTo: 0)
        .get()
        .then((value) => value.docs.map((e) => CloudCustomer.fromSnapshot(e)));
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

  // Future<Iterable<CloudCustomerHistory>> allUnpaidHistory(
  //     CloudCustomer customer) async {
  //   final town = await AppDocumentData.getTownName();
  //   return await FirebaseFirestore.instance
  //       .collection(
  //           '$town$customerDetailsCollection/${customer.documentId}/$historyCollection')
  //       .where(isPaidField, isEqualTo: false)
  //       .where(isVoidedField, isEqualTo: false)
  //       .get()
  //       .then((value) =>
  //           value.docs.map((doc) => CloudCustomerHistory.fromSnapshot(doc)));
  // }

  Future<Iterable<CloudCustomer>> searchFlaggedCustomer({
    required String userInput,
    required Iterable<CloudCustomer> customers,
  }) async {
    return customers.where((customer) =>
        (customer.bookId == userInput || customer.meterId == userInput));
  }

  Future<CloudCustomer> getCustomerFromDocId(String docId) async {
    final town = await AppDocumentData.getTownName();
    return await FirebaseFirestore.instance
        .doc('$town$customerDetailsCollection/$docId')
        .get()
        .then((value) => CloudCustomer.fromDocSnapshot(value))
        .onError((error, stackTrace) {
      dev.log(error.toString());
      throw NoSuchDocumentException();
    });
  }

  Future<CloudCustomer> getCustomer({
    // int? id,
    required String bookId,
  }) async {
    try {
      dev.log('here');
      return await getCustomerFromDocId(bookIdToDocId(bookId));
    } on NoSuchDocumentException {
      dev.log('passed Error From get custoemr from doc id');
      throw NoSuchDocumentException();
    }
  }

  Future<bool> customerExists({required String bookId}) async {
    try {
      await getCustomer(bookId: bookId);
    } on NoSuchDocumentException {
      return false;
    }
    return true;
  }

  Future<void> createCustomer({
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
      final prices = await getAllPrices();
      final detailsCollection = firebaseFirestoreInstance
          .collection('$town$customerDetailsCollection');
      final newCustomerDocRef = detailsCollection.doc(bookIdToDocId(bookId));

      final customerHistoryDocRef = FirebaseFirestore.instance
          .collection(
              '$town$customerDetailsCollection/${newCustomerDocRef.id}/$historyCollection')
          .doc();
      // final customerReceiptRef = firebaseFirestoreInstance.doc(
      //     '$town$customerDetailsCollection/${newCustomerDocRef.id}/$receiptCollection/${customerHistoryDocRef.id}');

      final customer = CloudCustomer(
        documentId: bookIdToDocId(bookId),
        bookId: bookId,
        meterId: meterId,
        name: name,
        address: address,
        lastUnit: meterReading,
        town: town,
        lastReadDate: pastMonthYearDate(),
        flag: false,
        debt: 0,
        adder: 0,
        horsePowerUnits: horsePowerUnits,
        meterMultiplier: meterMultiplier,
        hasRoadLightCost: hasRoadLight,
        lastHistory: customerHistoryDocRef,
      );

      await setDoc(
          document: newCustomerDocRef, dataFieldMap: customer.dataFieldMap());

      final history = CloudCustomerHistory(
        documentId: customerHistoryDocRef.id,
        previousUnit: meterReading,
        newUnit: meterReading,
        name: customer.name,
        bookId: customer.bookId,
        meterAllowance: 0,
        town: town,
        priceAtm: prices.pricePerUnit,
        cost: 0,
        date: pastMonthYearDate(),
        imageUrl:
            'https://firebasestorage.googleapis.com/v0/b/electricityplus-a6572.appspot.com/o/newUser%2Fptc%20black%20logo%20png.png?alt=media&token=5352fbb9-6396-4f71-af86-5d975c7fc20a',
        comment: 'Creation',
        isVoided: false,
        paidAmount: 0,
        inspector: FirebaseAuth.instance.currentUser!.displayName!,
        inspectorUid: FirebaseAuth.instance.currentUser!.uid,
        isPaid: true,
        serviceChargeAtm: prices.serviceCharge,
        horsePowerPerUnitCostAtm: prices.horsePowerPerUnitCost,
        horsePowerUnits: horsePowerUnits,
        meterMultiplier: meterMultiplier,
        roadLightPrice: hasRoadLight ? prices.roadLightPrice : 0,
      );

      await setDoc(
          document: customerHistoryDocRef,
          dataFieldMap: history.dataFieldMap());

    } on Exception {
      rethrow;
    }
  }

  Future<Iterable<CloudCustomer>> allCustomer() async {
    final town = await AppDocumentData.getTownName();
    return await firebaseFirestoreInstance
        .collection('$town$customerDetailsCollection')
        .get()
        .then((value) =>
            value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));
  }

  ///returns all read customer for the month.
  Future<Iterable<CloudCustomer>> allReadCustomer() async {
    final town = await AppDocumentData.getTownName();
    return await firebaseFirestoreInstance
        .collection('$town$customerDetailsCollection')
        .where(lastReadDateField,
            isGreaterThan: DateTime.now().toString().substring(0, 7))
        .get()
        .then((value) => value.docs.map((e) => CloudCustomer.fromSnapshot(e)));
  }

  ///update the firebase with updated customer and history values.
  ///return back the parameters.
  ///[0] customer, [1] history.
  Future<List<dynamic>> updateMeterAllowanceSubmission({
    required CloudCustomer customer,
    required CloudCustomerHistory history,
  }) async {
    final town = await AppDocumentData.getTownName();
    final customerRef = FirebaseFirestore.instance
        .doc('$town$customerDetailsCollection/${customer.documentId}');
    final historyRef = FirebaseFirestore.instance.doc(
        '$town$customerDetailsCollection/${customer.documentId}/$historyCollection/${history.documentId}');
    final batch = FirebaseFirestore.instance.batch();
    batch.update(customerRef, {debtField: customer.debt});
    batch.update(historyRef,
        {meterAllowanceField: history.meterAllowance, costField: history.cost});
    await batch.commit();
    return [customer, history];
  }

  ///returns [0] customer, [1] history, [2] receipt, which are the parameter
  ///themselves.
  Future<List<dynamic>> updatePaymentSubmission({
    required CloudReceipt receipt,
    required CloudCustomer customer,
    required CloudCustomerHistory history,
  }) async {
    final customerPath = receipt.customerDocRefPath();
    final customerRef = FirebaseFirestore.instance.doc(customerPath);
    final receiptRef = FirebaseFirestore.instance
        .doc('$customerPath/$receiptCollection/${receipt.documentId}');
    final historyRef =
        FirebaseFirestore.instance.doc(receipt.historyDocRefPath());
    final batch = FirebaseFirestore.instance.batch();
    try {
      batch.update(
        customerRef,
        {
          debtField: customer.debt,
          lastUnitField: history.newUnit,
        },
      );
      batch.update(
        historyRef,
        history.dataFieldMap(),
      );
      batch.set(
        receiptRef,
        receipt.dataFieldMap(),
      );
      batch.commit();
    } on Exception {
      throw CouldNotMakePaymentException();
    }
    return [customer, history, receipt];
  }

  Future<Iterable<CloudCustomer>> getUnreadCustomer() async {
    final town = await AppDocumentData.getTownName();
    return firebaseFirestoreInstance
        .collection('$town$customerDetailsCollection')
        .where(lastReadDateField, isLessThan: DateTime.now().toString())
        .get()
        .then((value) => value.docs.map((e) => CloudCustomer.fromSnapshot(e)));
  }

  Future<CloudReceipt> getReceipt(
      {required CloudCustomer customer,
      required CloudCustomerHistory history}) async {
    final town = await AppDocumentData.getTownName();
    final receiptDocRef = FirebaseFirestore.instance.doc(
        '$town$customerDetailsCollection/${customer.documentId}/$receiptCollection/${history.documentId}');
    final receipt = await receiptDocRef
        .get()
        .then((value) => CloudReceipt.fromDocSnapshot(value))
        .onError((error, stackTrace) {
      throw CouldNotFindReceiptDocException();
    });
    return receipt;
  }

  Future<void> importData({
    required PlatformFile platformFile,
    required String importDate,
  }) async {
    final prices = await getAllPrices();
    final town = await AppDocumentData.getTownName();
    final priceAtm = prices.pricePerUnit;
    final serviceCharge = prices.serviceCharge;
    final roadLightPrice = prices.roadLightPrice;
    final horsePowerPerUnitCost = prices.horsePowerPerUnitCost;
    final file = File(platformFile.path!);

    final lines =
        file.openRead().transform(utf8.decoder).transform(const LineSplitter());

    int count = 0;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    final writeCustomerCollection = FirebaseFirestore.instance
        .collection('$town$customerDetailsCollection/');
    await for (var line in lines) {
      final splitExpression = RegExp(",(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))");
      final splittedLine = line.split(splitExpression);
      dev.log(splittedLine.toString());
      if (isIntInput(splittedLine[0].trim())) {
        try {
          final name = splittedLine[3];
          final address = splittedLine[7];
          final bookId = splittedLine[6];
          final meterId = splittedLine[2];
          final previousMeterReading = num.parse(splittedLine[10].trim());
          final meterReading = num.parse(splittedLine[11].trim());
          final meterMultiplier = splittedLine[12].trim().isEmpty
              ? 1
              : num.parse(splittedLine[12].trim());
          final horsePowerUnits =
              num.parse(splittedLine[18].trim()) / horsePowerPerUnitCost;
          final hasRoadLight =
              num.parse(splittedLine[16].trim()) == 0 ? false : true;
          final customerDoc =
              writeCustomerCollection.doc(bookIdToDocId(bookId));
          final historyDoc = FirebaseFirestore.instance
              .collection('${customerDoc.path}/$historyCollection')
              .doc(importDate.substring(0, 7));
          final historyObj = CloudCustomerHistory(
            name: name,
            bookId: bookId,
            documentId: historyDoc.id,
            previousUnit: previousMeterReading,
            town: town,
            newUnit: meterReading,
            priceAtm: priceAtm,
            meterAllowance: 0,
            cost: 0,
            date: importDate,
            imageUrl:
                'https://firebasestorage.googleapis.com/v0/b/electricityplus-a6572.appspot.com/o/newUser%2Fptc%20black%20logo%20png.png?alt=media&token=5352fbb9-6396-4f71-af86-5d975c7fc20a',
            comment: '',
            isVoided: false,
            paidAmount: 0,
            inspector: '',
            inspectorUid: '',
            isPaid: true,
            serviceChargeAtm: serviceCharge,
            horsePowerPerUnitCostAtm: horsePowerPerUnitCost,
            horsePowerUnits: horsePowerUnits,
            meterMultiplier: meterMultiplier,
            roadLightPrice: roadLightPrice,
          );
          final customerObj = CloudCustomer(
            documentId: customerDoc.id,
            bookId: bookId,
            town: town,
            meterId: meterId,
            name: name,
            address: address,
            lastReadDate: importDate,
            lastUnit: meterReading,
            flag: false,
            debt: 0,
            adder: 0,
            horsePowerUnits: horsePowerUnits,
            meterMultiplier: meterMultiplier,
            hasRoadLightCost: hasRoadLight,
            lastHistory: historyDoc,
          );
          setDoc(
              document: customerDoc,
              dataFieldMap: customerObj.dataFieldMap(),
              batch: batch);
          setDoc(
              document: historyDoc,
              dataFieldMap: historyObj.dataFieldMap(),
              batch: batch);

          count += 4;
          if (count % 500 == 0) {
            batch.commit();
            batch = FirebaseFirestore.instance.batch();
          }
        } catch (e) {
          dev.log(splittedLine.toString());
        }
      }
    }
    batch.commit();
  }

  Future<void> setDoc({
    required DocumentReference<Map<String, dynamic>> document,
    required Map<String, dynamic> dataFieldMap,
    WriteBatch? batch,
  }) async {
    if (batch != null) {
      batch.set(document, dataFieldMap);
    } else {
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(document, dataFieldMap);
      });
    }
  }

  Future<CloudFlag> getFlaggedIssue({required CloudCustomer customer}) async {
    final town = await AppDocumentData.getTownName();
    return FirebaseFirestore.instance
        .collection(
            '$town$customerDetailsCollection/${customer.documentId}/$flagCollection')
        .get()
        .then((value) => CloudFlag.fromSnapshot(value.docs.first));
  }

  ///actualCustomer, tempCustomer, blankBill, exchangeBill, exchangeHistory in order
  Future<List<dynamic>> exchangeMeterSubmission({
    required CloudCustomer actualCustomer,
    required CloudCustomer tempCustomer,
    required CloudCustomerHistory blankBill,
    required CloudCustomerHistory exchangeBill,
    required CloudExchangeHistory exchangeHistory,
  }) async {
    final town = await AppDocumentData.getTownName();
    final tempCustomerDocRef = firebaseFirestoreInstance
        .doc('$town$customerDetailsCollection/${tempCustomer.documentId}');
    final actualCustomerDocRef = firebaseFirestoreInstance
        .doc('$town$customerDetailsCollection/${actualCustomer.documentId}');
    final blankBillDocRef = firebaseFirestoreInstance
        .collection(
            '$town$customerDetailsCollection/${actualCustomer.documentId}/$historyCollection')
        .doc(DateTime.now().toString().substring(0, 10));
    final exchangeBillDocRef = firebaseFirestoreInstance
        .collection(
            '$town$customerDetailsCollection/${tempCustomer.documentId}/$historyCollection')
        .doc(DateTime.now().toString().substring(0, 10));
    final exchangeHistoryDocRef = firebaseFirestoreInstance
        .collection(
            '$town$customerDetailsCollection/${actualCustomer.documentId}/$exchangeHistoryCollection')
        .doc(DateTime.now().toString().substring(0, 10));
    final batch = firebaseFirestoreInstance.batch();
    tempCustomer = tempCustomer.updateLastHistory(exchangeBillDocRef);

    actualCustomer = actualCustomer
        .debtDeduction(
          deductAmount:
              await voidCurrentMonthLastHistory(customer: actualCustomer),
        )
        .updateLastHistory(blankBillDocRef);
    setDoc(
      document: exchangeHistoryDocRef,
      dataFieldMap: exchangeHistory.dataFieldMap(),
      batch: batch,
    );
    setDoc(
      document: tempCustomerDocRef,
      dataFieldMap: tempCustomer.dataFieldMap(),
      batch: batch,
    );
    setDoc(
      document: actualCustomerDocRef,
      dataFieldMap: actualCustomer.dataFieldMap(),
      batch: batch,
    );
    setDoc(
      document: blankBillDocRef,
      dataFieldMap: blankBill.dataFieldMap(),
      batch: batch,
    );
    setDoc(
      document: exchangeBillDocRef,
      dataFieldMap: exchangeBill.dataFieldMap(),
      batch: batch,
    );
    batch.commit();
    return [
      actualCustomer,
      tempCustomer,
      blankBill,
      exchangeBill,
      exchangeHistory,
    ];
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
