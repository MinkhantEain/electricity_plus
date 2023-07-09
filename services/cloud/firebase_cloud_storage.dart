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
import 'package:electricity_plus/services/models/progress.dart';
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

  ///Stores the image in FirebaseStorage with customer's document Id as the folder name
  ///and the month-year date of the month the photo is taken as the name of the image.
  ///This is to reduce storage and to have only one actual image per month and the rest are unnecessary.
  Future<String> storeImage(String customerDocumentId, File file,
      {String fileName = ''}) async {
    try {
      final uploadTask = firebaseStorage
          .child(customerDocumentId)
          .child(currentMonthYearDate() + fileName)
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
    final town =  await AppDocumentData.getTownName();
    return FirebaseFirestore.instance.doc('$town$priceCollection/$priceDoc').get()
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
    final price = await getPrice();
    final previousUnit = await getPreviousValidUnit(customer);
    final serviceCharge = await getServiceCharge();
    final meterMultiplier = customer.meterMultiplier;
    final roadLightPrice = await getRoadLightPrice();
    final horsePowerPerUnitCost = await getHorsePowerPerUnitCost();
    final horsePowerUnits = customer.horsePowerUnits;
    final hasRoadLight = customer.hasRoadLightCost ? 1 : 0;
    final result = price * (newReading - previousUnit) * meterMultiplier +
        horsePowerUnits * horsePowerPerUnitCost +
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
    final flag = CloudFlag(
      date: DateTime.now().toString(),
      comment: comment,
      documentId: DateTime.now().toString().substring(0, 7),
      imageUrl: imageUrl,
      inspector: inspector,
      isResolved: false,
    );
    voidCurrentMonthLastHistory(customer: customer);
    final town = await AppDocumentData.getTownName();
    final flagDocRef = FirebaseFirestore.instance.doc(
        '$town$customerDetailsCollection/${customer.documentId}/$flagCollection/${flag.documentId}');
    //creates a flag collection
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(flagDocRef, {
        dateField: flag.date,
        commentField: flag.comment,
        imageUrlField: flag.imageUrl,
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
      });
    });
  }

  ///Get the previous valid unit a.k.a from the latest previous month
  //TODO: get it from the previous month in recent history collection doc
  Future<num> getPreviousValidUnit(CloudCustomer customer) async {
    final town = await AppDocumentData.getTownName();
    final customerHistoryCollection = firebaseFirestoreInstance.collection(
        '$town$customerDetailsCollection/${customer.documentId}/$historyCollection');
    final result = await customerHistoryCollection
        .where(dateField,
            isLessThanOrEqualTo: DateTime.now().toString().substring(0, 7))
        .where(isVoidedField, isEqualTo: false)
        .orderBy(dateField, descending: true)
        .get()
        .then((value) => value.docs);
    dev.log(result.isEmpty.toString());
    if (result.isEmpty) {
      return 0;
    } else {
      return result.first[newUnitField];
    }
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
  Future<void> voidCurrentMonthLastHistory({
    required CloudCustomer customer,
  }) async {
    final previousHistory = await customer.lastHistory.get();
    final previousHistoryDate = previousHistory[dateField];
    if (isWithinMonth(previousHistoryDate) && !previousHistory[isVoidedField]) {
      final town = await AppDocumentData.getTownName();
      customer.lastHistory.update({isVoidedField: true});
      if (!previousHistory[isPaidField]) {
        final debt = customer.debt - previousHistory[costField];
        await FirebaseFirestore.instance
            .doc('$town$customerDetailsCollection/${customer.documentId}')
            .update({
          debtField: debt,
        });
      }
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
      final unpaidBillDocRef = FirebaseFirestore.instance
          .collection(
              '$town$customerDetailsCollection/${customer.documentId}/$unpaidBillCollection')
          .doc(currentMonthYearDate());
      final recentBillHistoryDocRef = FirebaseFirestore.instance
          .collection(
              '$town$customerDetailsCollection/${customer.documentId}/$recentBillHistoryCollection')
          .doc(currentMonthYearDate());
      final batch = FirebaseFirestore.instance.batch();
      history = CloudCustomerHistory(
          documentId: customerHistoryDocRef.id,
          previousUnit: previousReading,
          newUnit: newReading,
          priceAtm: await getPrice(),
          cost: await calculateCost(customer, newReading),
          date: DateTime.now().toString(),
          imageUrl: imageUrl,
          comment: comment,
          isPaid: false,
          isVoided: false,
          paidAmount: 0,
          inspector: FirebaseAuth.instance.currentUser!.displayName!,
          serviceChargeAtm: await getServiceCharge(),
          horsePowerPerUnitCostAtm: await getHorsePowerPerUnitCost(),
          horsePowerUnits: customer.horsePowerUnits,
          meterMultiplier: customer.meterMultiplier,
          roadLightPrice: await getRoadLightPrice());

      //update the last history field and debt in customer
      final debt = (await customerDocRef.get())[debtField] + history.cost;
      batch.update(customerDocRef,
          {lastHistoryField: customerHistoryDocRef, debtField: debt});

      //creates a new history document
      batch.set(customerHistoryDocRef, {
        commentField: comment,
        costField: history.cost,
        dateField: history.date,
        horsePowerPerUnitCostAtmField: history.horsePowerPerUnitCostAtm,
        horsePowerUnitsField: customer.horsePowerUnits,
        imageUrlField: imageUrl,
        inspectorField: history.inspector,
        meterMultiplierField: customer.meterMultiplier,
        newUnitField: newReading,
        previousUnitField: history.previousUnit,
        priceAtmField: history.priceAtm,
        roadLightPriceField: history.roadLightPrice,
        paidAmountField: history.paidAmount,
        isPaidField: history.isPaid,
        isVoidedField: history.isVoided,
        serviceChargeField: history.serviceChargeAtm,
      });

      batch.set(
          recentBillHistoryDocRef, {referenceField: customerHistoryDocRef});

      batch.set(unpaidBillDocRef, {referenceField: customerHistoryDocRef});

      batch.commit();
    } catch (e) {
      rethrow;
    }
    return history;
  }

  Future<Iterable<CloudCustomerHistory>> getRecentBillHistory(
      {required CloudCustomer customer}) async {
    final town = await AppDocumentData.getTownName();
    final docRefs = await FirebaseFirestore.instance
        .collection(
            '$town$customerDetailsCollection/${customer.documentId}/$recentBillHistoryCollection')
        .get()
        .then((value) => value.docs
            .map((e) => e.data()[referenceField] as DocumentReference));

    final temp = docRefs.map((e) => e.get().then((value) =>
        CloudCustomerHistory.fromDocSnapshot(
            value as DocumentSnapshot<Map<String, dynamic>>)));
    return Future.wait(temp);
  }

  Future<Iterable<CloudCustomerHistory>> getUnpaidBill(
      {required CloudCustomer customer}) async {
    final town = await AppDocumentData.getTownName();
    final docRef = await FirebaseFirestore.instance
        .collection(
            '$town$customerDetailsCollection/${customer.documentId}/$unpaidBillCollection')
        .get()
        .then((value) => value.docs
            .map((doc) => doc.data()[referenceField] as DocumentReference));
    final temp = docRef.map((e) => e.get().then((value) =>
        CloudCustomerHistory.fromDocSnapshot(
            value as DocumentSnapshot<Map<String, dynamic>>)));
    return Future.wait(temp).then((value) => value.where((element) {
          dev.log(element.toString());
          dev.log(element.isVoided.toString());
          dev.log(
              (element.isVoided != true && element.isPaid != true).toString());
          return element.isVoided != true && element.isPaid != true;
        }));
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
    FirebaseFirestore.instance
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
      throw throw NoSuchDocumentException();
    });
  }

  String bookIdToDocId(String bookId) {
    return bookId.replaceAll(RegExp(r'/'), '-');
  }

  String docIdToBookId(String bookId) {
    return bookId.replaceAll(RegExp(r'-'), '/');
  }

  Future<CloudCustomer> getCustomer({
    // int? id,
    required String bookId,
  }) async {
    try {
      return await getCustomerFromDocId(bookIdToDocId(bookId));
    } on NoSuchDocumentException {
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
        debtField: 0,
        lastHistoryField: customerHistoryDocRef,
      });

      FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          transaction.set(customerHistoryDocRef, {
            previousUnitField: meterReading,
            newUnitField: meterReading,
            priceAtmField: await getPrice(),
            serviceChargeField: await getServiceCharge(),
            isVoidedField: false,
            dateField: pastMonthYearDate(),
            costField: 0,
            isPaidField: true,
            inspectorField: '',
            roadLightPriceField: hasRoadLight ? await getRoadLightPrice() : 0,
            meterMultiplierField: meterMultiplier,
            horsePowerUnitsField: horsePowerUnits,
            horsePowerPerUnitCostAtmField: await getHorsePowerPerUnitCost(),
            commentField: '',
            paidAmountField: 0,
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
        .get()
        .then((value) =>
            value.docs.map((doc) => CloudCustomer.fromSnapshot(doc)));
  }

  Future<void> makeFullPayment({
    required CloudReceipt receipt,
  }) async {
    final customerPath = receipt.customerDocRefPath();
    await FirebaseFirestore.instance
        .collection('$customerPath/$recentBillHistoryCollection')
        .doc(halfYearAgo())
        .delete();
    await FirebaseFirestore.instance
        .collection('$customerPath/$unpaidBillCollection')
        .doc(receipt.meterReadDate.substring(0, 7))
        .delete();
    final customerRef = FirebaseFirestore.instance.doc(customerPath);
    final receiptRef = FirebaseFirestore.instance
        .doc('$customerPath/$receiptCollection/${receipt.documentId}');
    final historyRef =
        FirebaseFirestore.instance.doc(receipt.historyDocRefPath());
    final batch = FirebaseFirestore.instance.batch();
    try {
      batch.update(customerRef, {
        debtField: (await customerRef.get())[debtField] - receipt.initialCost
      });
      batch.update(historyRef,
          {paidAmountField: receipt.initialCost, isPaidField: true});
      batch.set(receiptRef, {
        forDateField: receipt.forDate,
        meterReadDateField: receipt.meterReadDate,
        bookIdField: receipt.bookId,
        customerNameField: receipt.customerName,
        collectorNameField: receipt.collectorName,
        transactionDateField: receipt.transactionDate,
        paymentDueDateField: receipt.paymentDueDate,
        customerDocIdField: receipt.customerDocId,
        historyDocIdField: receipt.historyDocId,
        townNameField: receipt.townName,
        meterAllowanceField: receipt.meterAllowance,
        priceAtmField: receipt.priceAtm,
        initialCostField: receipt.initialCost,
        finalCostField: receipt.finalCost,
      });
      batch.commit();
    } on Exception {
      throw CouldNotMakePaymentException();
    }
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

  Future<void> importBillHistory(PlatformFile platformFile) async {
    //TODO
  }

  Future<void> importData(
      {required PlatformFile platformFile,
      required String importDate,}) async {
    final town = await AppDocumentData.getTownName();
    final priceAtm = await getPrice();
    final serviceCharge = await getServiceCharge();
    final roadLightPrice = await getRoadLightPrice();
    final horsePowerPerUnitCost = await getHorsePowerPerUnitCost();
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
          final horsePowerUnits =
              num.parse(splittedLine[18].trim()) / horsePowerPerUnitCost;
          final hasRoadLight =
              num.parse(splittedLine[16].trim()) == 0 ? false : true;
          final customerDoc =
              writeCustomerCollection.doc(bookIdToDocId(bookId));
          final historyDoc = FirebaseFirestore.instance
              .collection('${customerDoc.path}/$historyCollection')
              .doc();
          final recentBillDocRef = FirebaseFirestore.instance
              .collection(
                  '$town$customerDetailsCollection/${bookIdToDocId(bookId)}/$recentBillHistoryCollection')
              .doc(importDate.substring(0, 7));
          final historyObj = CloudCustomerHistory(
            documentId: historyDoc.id,
            previousUnit: meterReading,
            newUnit: meterReading,
            priceAtm: priceAtm,
            cost: 0,
            date: importDate,
            imageUrl:
                'https://firebasestorage.googleapis.com/v0/b/electricityplus-a6572.appspot.com/o/newUser%2Fsoil.jpg?alt=media&token=93cdbd32-72a3-4992-a134-226d465c340f',
            comment: '',
            isVoided: false,
            paidAmount: 0,
            inspector: '',
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
            meterId: meterId,
            name: name,
            address: address,
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
          setDoc(
              document: recentBillDocRef,
              dataFieldMap: {referenceField: historyDoc},
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

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
