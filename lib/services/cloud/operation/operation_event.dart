import 'dart:io';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/cloud_customer_history.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class OperationEvent {
  const OperationEvent();
}


class OperationEventChooseTown extends OperationEvent {
  const OperationEventChooseTown();
}

class OperationEventDefault extends OperationEvent {
  const OperationEventDefault();
}

class OperationEventInitialise extends OperationEvent {
  const OperationEventInitialise();
}

class OperationEventReceiptGeneration extends OperationEvent {
  final CloudCustomer customer;
  final CloudCustomerHistory customerHistory;
  const OperationEventReceiptGeneration(
      {required this.customer, required this.customerHistory});
}

class OperationEventSetPriceIntention extends OperationEvent {
  const OperationEventSetPriceIntention();
}

class OperationEventSetPrice extends OperationEvent {
  final String price;
  final String tokenInput;
  final String serviceCharge;
  final String horsePowerPerUnitCost;
  final String roadLightPrice;
  final bool isSettingPrice;
  const OperationEventSetPrice({
    required this.price,
    required this.tokenInput,
    required this.serviceCharge,
    required this.isSettingPrice,
    required this.horsePowerPerUnitCost,
    required this.roadLightPrice,
  });
}

class OperationEventFetchCustomerReceiptHistory extends OperationEvent {
  final CloudCustomer customer;
  const OperationEventFetchCustomerReceiptHistory({
    required this.customer,
  });
}

class OperationEventCustomerReceiptSearch extends OperationEvent {
  final String userInput;
  final bool isSearching;
  const OperationEventCustomerReceiptSearch({
    required this.isSearching,
    required this.userInput,
  });
}

class OperationEventElectricLogSearch extends OperationEvent {
  final String userInput;
  final bool isSearching;
  const OperationEventElectricLogSearch({
    required this.userInput,
    required this.isSearching,
  });
}

class OperationEventFlagCustomerSearch extends OperationEvent {
  final String userInput;
  final bool isSearching;
  const OperationEventFlagCustomerSearch({
    required this.userInput,
    required this.isSearching,
  });
}

class OperationEventCreateNewElectricLog extends OperationEvent {
  final CloudCustomer customer;
  final String newReading;
  const OperationEventCreateNewElectricLog({
    required this.customer,
    required this.newReading,
  });
}

class OperationEventImageCommentFlag extends OperationEvent {
  final CloudCustomer customer;
  final DocumentReference newHistory;
  const OperationEventImageCommentFlag({
    required this.customer,
    required this.newHistory,
  });
}

class OperationEventLogSubmission extends OperationEvent {
  final CloudCustomer customer;
  final File image;
  final String comment;
  final bool flag;
  final num newReading;
  const OperationEventLogSubmission({
    required this.customer,
    required this.image,
    required this.comment,
    required this.flag,
    required this.newReading,
  });
}

class OperationEventResolveIssue extends OperationEvent {
  final CloudCustomer customer;
  final bool resolved;
  final String newComment;
  const OperationEventResolveIssue({
    required this.customer,
    required this.resolved,
    required this.newComment,
  });
}

class OperationEventAddCustomer extends OperationEvent {
  final String? meterId;
  final String? address;
  final String? name;
  final String? bookId;
  final String? meterReading;
  final String? horsePowerUnits;
  final String? meterMultiplier;
  final bool? hasRoadLight;
  const OperationEventAddCustomer({
    this.address,
    this.bookId,
    this.meterId,
    this.meterReading,
    this.name,
    this.horsePowerUnits,
    this.meterMultiplier,
    this.hasRoadLight,
  });
}

class OperationEventAdminView extends OperationEvent {
  const OperationEventAdminView();
}

class OperationEventInitialiseData extends OperationEvent {
  final PlatformFile? result;
  final bool submit;
  const OperationEventInitialiseData(
      {required this.result, required this.submit});
}

class OperationEventInitialiseDataSubmission extends OperationEvent {
  final PlatformFile? result;
  const OperationEventInitialiseDataSubmission({required this.result});
}

class OperationEventProduceExcel extends OperationEvent {
  const OperationEventProduceExcel();
}

class OperationEventAddNewTown extends OperationEvent {
  final String townName;
  final String token;
  const OperationEventAddNewTown({
    required this.townName,
    required this.token,
  });
}

class OperationEventDeleteTown extends OperationEvent {
  final String townName;
  final String token;
  const OperationEventDeleteTown({
    required this.token,
    required this.townName,
  });
}

class OperationEventChooseBluetooth extends OperationEvent {
  const OperationEventChooseBluetooth();
}

class OperationEventPrintBill extends OperationEvent {
  final List<LineText> printDetails;
  const OperationEventPrintBill({required this.printDetails});
}