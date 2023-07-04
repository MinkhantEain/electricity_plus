import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/services/others/town.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class OperationState {
  final bool isLoading;
  final String? loadingText;
  const OperationState({
    required this.isLoading,
    this.loadingText,
  });
}

class OperationStateChooseTown extends OperationState {
  final Iterable<Town> towns;
  final Exception? exception;
  const OperationStateChooseTown({
    required bool isLoading,
    required this.towns,
    required this.exception,
  }) : super(isLoading: isLoading);
}

class OperationStateDefault extends OperationState {
  final String townName;
  const OperationStateDefault({required this.townName})
      : super(isLoading: false);
}

class OperationStateUninitialised extends OperationState {
  const OperationStateUninitialised({required bool isLoading})
      : super(isLoading: isLoading);
}

class OperationStateSearchingCustomerHistory extends OperationState {
  final Exception? exception;
  final Iterable<CloudCustomer> customerIterable;
  const OperationStateSearchingCustomerHistory({
    required this.exception,
    required bool isLoading,
    required this.customerIterable,
  }) : super(isLoading: isLoading);
}

class OperationStateGeneratingBill extends OperationState {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const OperationStateGeneratingBill(
      {required this.customer, required this.history})
      : super(isLoading: false);
}

class OperationStateSettingPrice extends OperationState {
  final Exception? exception;
  final String currentPrice;
  final String currentServiceCharge;
  final String currentHorsePowerPerUnitCost;
  final String currentRoadLightPrice;
  const OperationStateSettingPrice({
    required this.exception,
    required this.currentPrice,
    required this.currentServiceCharge,
    required bool isLoading,
    required this.currentHorsePowerPerUnitCost,
    required this.currentRoadLightPrice,
  }) : super(isLoading: isLoading);
}

class OperationStateFetchingCustomerHistory extends OperationState {
  final Iterable<CloudCustomerHistory> customerHistory;
  final CloudCustomer customer;
  const OperationStateFetchingCustomerHistory({
    required bool isLoading,
    required this.customerHistory,
    required this.customer,
  }) : super(isLoading: isLoading);
}

class OperationStateElectricLogSearch extends OperationState {
  const OperationStateElectricLogSearch() : super(isLoading: false);
}

class OperationStatePayment extends OperationState {
  final String qrCode;
  const OperationStatePayment({required this.qrCode}) : super(isLoading: false);
}

class OpeartionStateFlagCustomerSearch extends OperationState {
  final Exception? exception;
  final Iterable<CloudCustomer> customers;
  const OpeartionStateFlagCustomerSearch(
      {required this.exception,
      required this.customers,
      required bool isLoading})
      : super(isLoading: isLoading);
}

class OperationStateCreatingNewElectricLog extends OperationState {
  final CloudCustomer customer;
  final Exception? exception;
  final num lastUnit;
  const OperationStateCreatingNewElectricLog({
    required this.customer,
    required bool isLoading,
    required this.exception,
    required this.lastUnit,
  }) : super(isLoading: isLoading);
}

class OperationStateImageCommentFlag extends OperationState {
  final CloudCustomer customer;
  final Exception? exception;
  final num newReading;
  const OperationStateImageCommentFlag({
    required this.customer,
    required bool isLoading,
    required this.exception,
    required this.newReading,
  }) : super(isLoading: isLoading);
}

class OperationStateResolveIssue extends OperationState {
  final String date;
  final String previousComment;
  final CloudCustomer customer;
  final Exception? exception;
  final bool resolved;
  const OperationStateResolveIssue(
      {required this.date,
      required this.previousComment,
      required bool isLoading,
      required this.customer,
      required this.exception,
      required this.resolved})
      : super(isLoading: isLoading);
}

class OperationStateAddCustomer extends OperationState {
  const OperationStateAddCustomer() : super(isLoading: false);
}

class OperationStateAdminView extends OperationState {
  final Exception? exception;
  const OperationStateAdminView(
      {required bool isLoading, required this.exception})
      : super(isLoading: isLoading);
}

class OperationStateInitialiseData extends OperationState {
  final Exception? exception;
  final FilePickerResult? pickedFile;
  final String fileName;
  final String fileBytes;
  final String fileSize;
  final String fileExtension;
  final String filePath;
  final PlatformFile? platformFile;
  const OperationStateInitialiseData(
      {required bool isLoading,
      required this.exception,
      required this.pickedFile,
      required this.fileName,
      required this.fileBytes,
      required this.fileExtension,
      required this.filePath,
      required this.fileSize,
      this.platformFile})
      : super(isLoading: isLoading);
}

class OperationStateProduceExcel extends OperationState {
  final Exception? exception;
  const OperationStateProduceExcel({
    required isLoading,
    required this.exception,
  }) : super(isLoading: isLoading);
}

class OperationStateChooseBluetooth extends OperationState {
  const OperationStateChooseBluetooth({required bool isLoading})
      : super(isLoading: isLoading);
}
