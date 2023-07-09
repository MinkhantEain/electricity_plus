import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/models/cloud_receipt_model.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'bill_receipt_event.dart';
part 'bill_receipt_state.dart';

class BillReceiptBloc extends Bloc<BillReceiptEvent, BillReceiptState> {
  BillReceiptBloc(FirebaseCloudStorage provider)
      : super(const BillReceiptInitial()) {
    on<BillInitialise>((event, emit) {
      emit(const BillReceiptLoading());
      emit(BillInitialised(customer: event.customer, history: event.history));
    });

    on<BillFromFlaggedInitialise>(
      (event, emit) {
        emit(const BillReceiptLoading());
        emit(BillFromFlaggedInitialised(
          customer: event.customer,
          history: event.history,
        ));
      },
    );

    on<BillQrInitialise>((event, emit) async {
      emit(const BillReceiptLoading());
      //index 0 is customer doc id, index 1 is history doc id
      final qrCodeData = event.qrCode.split('/');
      try {
        final customer = await provider.getCustomerFromDocId(qrCodeData[0]);
        final history = await provider.getCusomerHistoryFromQrCode(qrCodeData);
        emit(BillInitialised(customer: customer, history: history));
      } on Exception catch (e) {
        if (e is NoSuchDocumentException) {
          emit(const BillReceiptErrorNotFound());
          emit(const BillReceiptInitial());
        }
      }
    });

    on<BillFromHistorySearchInitialise>(
      (event, emit) {
        emit(const BillReceiptLoading());
        emit(BillFromHistorySearchInitialised(
          customer: event.customer,
          history: event.history,
        ));
      },
    );

    on<BillReceiptPaymentEvent>(
      (event, emit) async {
        emit(const BillReceiptLoading());
        final meterAllowance = event.meterAllowance;

        if (isIntInput(meterAllowance)) {
          //note: the document id is not determined here
          try {
            final receipt = CloudReceipt(
                documentId: event.history.documentId,
                forDate: monthYearWordFormat(previousMonthYearDateNumericFormat(
                    date: event.history.date)),
                meterReadDate: event.history.date,
                bookId: event.customer.bookId,
                customerName: event.customer.name,
                collectorName: FirebaseAuth.instance.currentUser!.displayName!,
                transactionDate: DateTime.now().toString(),
                paymentDueDate: paymentDueDate(event.history.date),
                customerDocId: event.customer.documentId,
                historyDocId: event.history.documentId,
                townName: await AppDocumentData.getTownName(),
                meterAllowance: num.parse(meterAllowance),
                priceAtm: event.history.priceAtm,
                initialCost: event.history.cost,
                finalCost: event.history.cost -
                    (num.parse(meterAllowance) * event.history.priceAtm));
            await provider.makeFullPayment(receipt: receipt);
            emit(const BillReceiptPaymentRecordedSuccessfully());
            emit(BillReceiptPaymentState(
              customer: event.customer,
              history: event.history,
              receipt: receipt,
            ));
          } on CouldNotMakePaymentException {
            emit(const PaymentError());
            emit(BillInitialised(
                customer: event.customer, history: event.history));
          }
        } else {
          emit(InvalidMeterAllowanceInput(input: meterAllowance));
          emit(MeterAllowanceAcquisitonState(
              customer: event.customer, history: event.history));
        }
      },
    );

    on<ReopenReceiptEvent>(
      (event, emit) async {
        try {
          emit(BillReceiptPaymentState(
              customer: event.customer,
              history: event.history,
              receipt: await provider.getReceipt(
                  customer: event.customer, history: event.history)));
        } on CouldNotFindReceiptDocException {
          emit(const ReceiptRetrievalUnsuccessful());
          emit(BillInitialised(
              customer: event.customer, history: event.history));
        }
      },
    );

    on<MeterAllowanceAcquisitionEvent>(
      (event, emit) async {
        //This will direct the page to meter allowance aquisition page
        emit(MeterAllowanceAcquisitonState(
            customer: event.customer, history: event.history));
      },
    );

    on<BillPrinterConnectEvent>(
      (event, emit) {
        emit(const BillReceiptLoading());
        emit(BillPrinterNotConnected(
            customer: event.customer, history: event.history));
      },
    );

    on<ReceiptPrinterConnectEvent>(
      (event, emit) {
        emit(const BillReceiptLoading());
        emit(ReceiptPrinterNotConnected(
          customer: event.customer,
          history: event.history,
        ));
      },
    );
  }
}
