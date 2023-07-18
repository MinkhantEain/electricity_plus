import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';

class CloudReceipt {
  final String documentId;
  final String forDate;
  final String meterReadDate;
  final String bookId;
  final String customerName;
  final String collectorName;
  final String transactionDate;
  final String bank;
  final String transactionId;
  final String paymentMethod;
  final String paymentDueDate;
  final String customerDocId;
  final String historyDocId;
  final String townName;
  final String bankTransactionDate;
  final num paidAmount;
  final num meterAllowance;
  final num priceAtm;
  final num cost;

  const CloudReceipt({
    required this.documentId,
    required this.bank,
    required this.paidAmount,
    required this.paymentMethod,
    required this.transactionId,
    required this.forDate,
    required this.meterReadDate,
    required this.bookId,
    required this.customerName,
    required this.collectorName,
    required this.bankTransactionDate,
    required this.transactionDate,
    required this.paymentDueDate,
    required this.customerDocId,
    required this.historyDocId,
    required this.townName,
    required this.meterAllowance,
    required this.priceAtm,
    required this.cost,
  });

  Map<String, dynamic> dataFieldMap() {
    return {
      forDateField: forDate,
      meterReadDateField: meterReadDate,
      bookIdField: bookId,
      customerNameField: customerName,
      collectorNameField: collectorName,
      transactionDateField: transactionDate,
      paymentDueDateField: paymentDueDate,
      customerDocIdField: customerDocId,
      bankTransactionDateField: bankTransactionDate,
      historyDocIdField: historyDocId,
      townNameField: townName,
      meterAllowanceField: meterAllowance,
      priceAtmField: priceAtm,
      costField: cost,
      transactionIdField: transactionId,
      paidAmountField: paidAmount,
      bankField: bank,
      paymentMethodField: paymentMethod,
    };
  }

  String customerDocRefPath() {
    return '$townName$customerDetailsCollection/$customerDocId';
  }

  ///It takes the new paidamount and adds it with the previous value.
  CloudReceipt addPaidAmount(num newPaidAmount) {
    final resultPaidAmount = (paidAmount + newPaidAmount) >= cost
        ? cost
        : (paidAmount + newPaidAmount);
    return CloudReceipt(
      documentId: documentId,
      bank: bank,
      paidAmount: resultPaidAmount,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      bankTransactionDate: bankTransactionDate,
      forDate: forDate,
      meterReadDate: meterReadDate,
      bookId: bookId,
      customerName: customerName,
      collectorName: collectorName,
      transactionDate: transactionDate,
      paymentDueDate: paymentDueDate,
      customerDocId: customerDocId,
      historyDocId: historyDocId,
      townName: townName,
      meterAllowance: meterAllowance,
      priceAtm: priceAtm,
      cost: cost,
    );
  }

  String historyDocRefPath() {
    return '${customerDocRefPath()}/$historyCollection/$historyDocId';
  }

  CloudReceipt.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        forDate = snapshot.data()[forDateField],
        meterReadDate = snapshot.data()[meterReadDateField],
        bookId = snapshot.data()[bookIdField],
        customerName = snapshot.data()[customerNameField],
        collectorName = snapshot.data()[collectorNameField],
        transactionDate = snapshot.data()[transactionDateField],
        paymentDueDate = snapshot.data()[paymentDueDateField],
        customerDocId = snapshot.data()[customerDocIdField],
        historyDocId = snapshot.data()[historyDocIdField],
        townName = snapshot.data()[townNameField],
        meterAllowance = snapshot.data()[meterAllowanceField],
        priceAtm = snapshot.data()[priceAtmField],
        cost = snapshot.data()[costField],
        paidAmount = snapshot.data()[paidAmountField],
        transactionId = snapshot.data()[transactionIdField],
        bankTransactionDate = snapshot.data()[bankTransactionDateField],
        paymentMethod = snapshot.data()[paymentMethodField],
        bank = snapshot.data()[bankField];

  CloudReceipt.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        forDate = snapshot.data()![forDateField],
        meterReadDate = snapshot.data()![meterReadDateField],
        bookId = snapshot.data()![bookIdField],
        customerName = snapshot.data()![customerNameField],
        collectorName = snapshot.data()![collectorNameField],
        transactionDate = snapshot.data()![transactionDateField],
        paymentDueDate = snapshot.data()![paymentDueDateField],
        bankTransactionDate = snapshot.data()![bankTransactionDateField],
        customerDocId = snapshot.data()![customerDocIdField],
        historyDocId = snapshot.data()![historyDocIdField],
        townName = snapshot.data()![townNameField],
        priceAtm = snapshot.data()![priceAtmField],
        meterAllowance = snapshot.data()![meterAllowanceField],
        cost = snapshot.data()![costField],
        paidAmount = snapshot.data()![paidAmountField],
        transactionId = snapshot.data()![transactionIdField],
        paymentMethod = snapshot.data()![paymentMethodField],
        bank = snapshot.data()![bankField];

  String receiptNo() {
    return historyDocId.substring(5, 7) +
        historyDocId.substring(5, 7) +
        historyDocId.substring(3, 5) +
        historyDocId.substring(11, 13) +
        historyDocId.substring(3, 4) +
        meterReadDate.substring(3, 4) +
        priceAtm.toString().substring(1, 3);
  }

  String finalCostCalculation() {
    final finalCost = cost - (priceAtm * meterAllowance);
    return '$cost - $priceAtm X $meterAllowance = $finalCost';
  }

  CloudReceipt reclibrateMeterAllowanceCost({required num newMeterAllowance}) {
    return CloudReceipt(
      documentId: documentId,
      bank: bank,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      forDate: forDate,
      meterReadDate: meterReadDate,
      bookId: bookId,
      customerName: customerName,
      collectorName: collectorName,
      transactionDate: transactionDate,
      bankTransactionDate: bankTransactionDate,
      paymentDueDate: paymentDueDate,
      customerDocId: customerDocId,
      historyDocId: historyDocId,
      townName: townName,
      meterAllowance: newMeterAllowance,
      priceAtm: priceAtm,
      cost: cost,
    );
  }

  CloudReceipt updateTransactionDetails({
    required String bankName,
    required String transactionId,
    required String bankTransactionDate,
    required String paymentMethod,
  }) {
    return CloudReceipt(
      documentId: documentId,
      bank: bankName,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      forDate: forDate,
      meterReadDate: meterReadDate,
      bookId: bookId,
      customerName: customerName,
      collectorName: collectorName,
      bankTransactionDate: bankTransactionDate,
      transactionDate: transactionDate,
      paymentDueDate: paymentDueDate,
      customerDocId: customerDocId,
      historyDocId: historyDocId,
      townName: townName,
      meterAllowance: meterAllowance,
      priceAtm: priceAtm,
      cost: cost,
    );
  }

  @override
  String toString() {
    return """ 
    documentId = $documentId
    forDate = $forDate
    meterReadDate = $meterReadDate
    bookId = $bookId
    customerName = $customerName
    collectorName = $collectorName
    transactionDate = $transactionDate
    paymentDueDate = $paymentDueDate
    customerDocId = $customerDocId
    historyDocId = $historyDocId
    townName = $townName
    priceAtm = $priceAtm
    meterAllowance = $meterAllowance
    cost = $cost
    """;
  }
}
