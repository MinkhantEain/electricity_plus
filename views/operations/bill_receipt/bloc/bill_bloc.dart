import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:equatable/equatable.dart';

part 'bill_event.dart';
part 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  BillBloc({required FirebaseCloudStorage provider})
      : super(const BillInitial()) {
    on<BillEventQrCodeInitialise>(
      (event, emit) async {
        emit(const BillStateLoading());
        final qrCodeData = event.qrCode.split('/');
        try {
          final customer = await provider.getCustomerFromDocId(qrCodeData[0]);
          final history =
              await provider.getCusomerHistoryFromQrCode(qrCodeData);
          final historyList =
              await provider.getRecentBillHistory(customer: customer);
          emit(BillInitialised(
            customer: customer,
            history: history,
            historyList: historyList,
          ));
        } on Exception catch (e) {
          if (e is NoSuchDocumentException) {
            emit(const BillStateNotFoundError());
          }
        }
      },
    );

    on<BillEventConnectPrinter>(
      (event, emit) {
        emit(const BillStateLoading());
        emit(const BillStatePrinterNotConnected());
        emit(event.resumeState);
      },
    );

    on<BillEventInitialise>(
      (event, emit) {
        emit(const BillStateLoading());
        emit(BillInitialised(
          customer: event.customer,
          history: event.customerHistory,
          historyList: event.historyList,
        ));
      },
    );

    on<BillEventMeterAllowanceRecliberation>(
      (event, emit) async {
        emit(const BillStateLoading());
        final meterAllowance = event.meterAllowance;
        if (!isIntInput(meterAllowance)) {
          emit(BillStateInvalidMeterAllowance(
              errorMessage:
                  'MeterAllowance: $meterAllowance, is not a valid input'));
          emit(BillInitialised(
            customer: event.customer,
            history: event.customerHistory,
            historyList: event.historyList,
          ));
        } else {
          final parsedMeterAllowance = num.parse(meterAllowance);
          if (parsedMeterAllowance > event.customerHistory.getUnitUsed()) {
            emit(BillStateInvalidMeterAllowance(
                errorMessage:
                    'MeterAllowance: $meterAllowance, cannot be greater than unit used'));
            emit(BillInitialised(
              customer: event.customer,
              history: event.customerHistory,
              historyList: event.historyList,
            ));
          } else {
            //recliberate customer history
            final customerHistory = event.customerHistory
                .changeMeterAllowance(newMeterAllowance: parsedMeterAllowance);
            final customerDebtToBeChangedAmt = event.customerHistory
                .meterAllowanceDebtChangeAmt(
                    newMeterAllowance: parsedMeterAllowance);
            //recliberate custoemr debt
            //minus meter allowance cost from customer debt
            final customer = event.customer
                .debtDeduction(deductAmount: customerDebtToBeChangedAmt);
            //submit it to cloud
            await provider.updateMeterAllowanceSubmission(
                customer: customer, history: customerHistory);
            //emit the updated bill
            emit(BillInitialised(
              customer: customer,
              history: customerHistory,
              historyList: event.historyList,
            ));
          }
        }
      },
    );

    on<BillEventReopenReceipt>(
      (event, emit) {
        emit(const BillStateLoading());
        emit(BillStateReopenReceipt(
          customer: event.customer,
          customerHistory: event.customerHistory,
        ));
        emit(BillInitialised(
          customer: event.customer,
          history: event.customerHistory,
          historyList: const [],
        ));
      },
    );

    on<BillEventMakePayment>(
      (event, emit) {
        emit(const BillStateLoading());
        emit(BillStateMakePayment(
          customer: event.customer,
          customerHistory: event.customerHistory,
        ));
      },
    );
  }
}
