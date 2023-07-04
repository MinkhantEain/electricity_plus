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
  final String paymentDueDate;
  final String customerDocId;
  final String historyDocId;
  final String townName;
  final num meterAllowance;
  final num priceAtm;
  final num initialCost;

  const CloudReceipt({
    required this.documentId,
    required this.forDate,
    required this.meterReadDate,
    required this.bookId,
    required this.customerName,
    required this.collectorName,
    required this.transactionDate,
    required this.paymentDueDate,
    required this.customerDocId,
    required this.historyDocId,
    required this.townName,
    required this.meterAllowance,
    required this.priceAtm,
    required this.initialCost,
  });

  String customerDocRefPath() {
    return '$townName$customerDetailsCollection/$customerDocId';
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
        initialCost = snapshot.data()[initialCostField];

  CloudReceipt.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        forDate = snapshot.data()![forDateField],
        meterReadDate = snapshot.data()![meterReadDateField],
        bookId = snapshot.data()![bookIdField],
        customerName = snapshot.data()![customerNameField],
        collectorName = snapshot.data()![collectorNameField],
        transactionDate = snapshot.data()![transactionDateField],
        paymentDueDate = snapshot.data()![paymentDueDateField],
        customerDocId = snapshot.data()![customerDocIdField],
        historyDocId = snapshot.data()![historyDocIdField],
        townName = snapshot.data()![townNameField],
        priceAtm = snapshot.data()![priceAtmField],
        meterAllowance = snapshot.data()![meterAllowanceField],
        initialCost = snapshot.data()![initialCostField];

  String costOutputType() {
    return meterAllowance == 0 ? 'Cost' : 'Final Cost';
  }

  String receiptNo() {
    return customerDocId.substring(4, 6) +
        historyDocId.substring(5, 7) +
        customerDocId.substring(1, 3) +
        customerDocId.substring(11, 13) +
        historyDocId.substring(5, 7) +
        customerDocId.substring(5, 7) +
        historyDocId.substring(3, 5) +
        historyDocId.substring(11, 13);
  }

  String finalCostCalculation() {
    final finalCost = initialCost - (priceAtm * meterAllowance);
    return '$initialCost - $priceAtm X $meterAllowance = $finalCost';
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
    initialCost = $initialCost
    """;
  }
}
