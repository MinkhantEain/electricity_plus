import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/models/cloud_receipt_model.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';

CloudCustomer customerDummy = CloudCustomer(
    documentId: '1Aff4yZvfa0QagUd7IHN',
    bookId: 'A1/04/08',
    meterId: '2020-12083979',
    name: 'ဦးအိုမဲ',
    address: '(၁၀)မိုင် တာညုံပါဒ ကော့သောင်း',
    lastUnit: 375,
    flag: false,
    adder: 0,
    horsePowerUnits: 0,
    meterMultiplier: 1,
    hasRoadLightCost: false,
    lastHistory: FirebaseFirestore.instance.doc(
        'CustomerDetails/1Aff4yZvfa0QagUd7IHN/History/swzCNGKkol8SMc18l8zc'));

CloudCustomerHistory historyDummy = const CloudCustomerHistory(
    documentId: 'swzCNGKkol8SMc18l8zc',
    previousUnit: 375,
    newUnit: 377,
    priceAtm: 500,
    cost: 1000,
    date: '2022-06-01',
    imageUrl: '2022-06-01',
    comment: 'comment',
    isVoided: false,
    isPaid: false,
    inspector: 'paing',
    serviceChargeAtm: 500,
    horsePowerPerUnitCostAtm: 200,
    horsePowerUnits: 1,
    meterMultiplier: 2,
    roadLightPrice: 3);

CloudReceipt receiptDummy = const CloudReceipt(
    documentId: 'QHYMABI0RNjQSGLcDf84',
    forDate: '01/02/2023',
    meterReadDate: '04/03/2023',
    bookId: 'A1/01/01',
    customerName: 'Paing',
    collectorName: 'Khant kyaw',
    transactionDate: '18/03/2023',
    paymentDueDate: '20/03/2023',
    customerDocId: 'U1btirkQilYMih1VmUcZ',
    historyDocId: 'QHYMABI0RNjQSGLcDf84',
    townName: 'Dummy Town',
    meterAllowance: 0,
    priceAtm: 30,
    initialCost: 100);
