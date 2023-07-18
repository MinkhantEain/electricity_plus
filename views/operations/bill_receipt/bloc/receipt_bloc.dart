import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/services/models/cloud_receipt_model.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/bill_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'receipt_event.dart';
part 'receipt_state.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  ReceiptBloc({required FirebaseCloudStorage provider})
      : super(ReceiptInitial()) {
    on<ReceiptEventConnectPrinter>(
      (event, emit) {
        emit(const ReceiptStateLoading());
        emit(const ReceiptStatePrinterNotConnected());
        emit(event.resumeState);
      },
    );

    on<ReceiptEventReopenReceipt>(
      (event, emit) async {
        emit(const ReceiptStateLoading());
        try {
          final receipt = await provider.getReceipt(
            customer: event.customer,
            history: event.customerHistory,
          );
          emit(
            ReceiptStateReceiptView(
                customer: event.customer,
                customerHistory: event.customerHistory,
                receipt: receipt),
          );
        } on CouldNotFindReceiptDocException {
          emit(const ReceiptStateReceiptRetrievalError());
        }
      },
    );

    on<ReceiptEventMakePayment>(
      (event, emit) async {
        emit(const ReceiptStateLoading());
        if (!isIntInput(event.paidAmount)) {
          emit(const ReceiptStateInvalidPaidAmountError());
          emit(ReceiptStatePaymentDetailsAcquitision(
            customer: event.customer,
            customerHistory: event.customerHistory,
          ));
        } else {
          final tempPA = num.parse(event.paidAmount);
          if (tempPA >
              (event.customerHistory.cost - event.customerHistory.paidAmount)) {
            emit(const ReceiptStatePaidAmountMoreThanRequiredError());
            emit(ReceiptStatePaymentDetailsAcquitision(
              customer: event.customer,
              customerHistory: event.customerHistory,
            ));
          } else {
            final paidAmount = num.parse(event.paidAmount);
            CloudReceipt receipt;
            try {
              receipt = await provider.getReceipt(
                  customer: event.customer, history: event.customerHistory);
              receipt = receipt.updateTransactionDetails(
                  bankName: event.bank,
                  transactionId: event.transactionId,
                  bankTransactionDate: event.transactionDate,
                  paymentMethod: event.paymentMethod);
            } on CouldNotFindReceiptDocException {
              receipt = CloudReceipt(
                documentId: event.customerHistory.documentId,
                bank: event.bank,
                paidAmount: 0,
                paymentMethod: event.paymentMethod,
                transactionId: event.transactionId,
                bankTransactionDate: event.transactionDate,
                forDate: monthYearWordFormat(previousMonthYearDateNumericFormat(
                    date: event.customerHistory.date)),
                meterReadDate: event.customerHistory.date,
                bookId: event.customer.bookId,
                customerName: event.customer.name,
                collectorName: FirebaseAuth.instance.currentUser!.displayName!,
                transactionDate: DateTime.now().toString(),
                paymentDueDate: paymentDueDate(event.customerHistory.date),
                customerDocId: event.customer.documentId,
                historyDocId: event.customerHistory.documentId,
                townName: await AppDocumentData.getTownName(),
                meterAllowance: event.customerHistory.meterAllowance,
                priceAtm: event.customerHistory.priceAtm,
                cost: event.customerHistory.cost,
              );
            }
            CloudCustomerHistory history = event.customerHistory;
            CloudCustomer customer = event.customer;

            //add paid amount to receipt and update history
            //paid amount using receipt's
            receipt = receipt.addPaidAmount(paidAmount);
            history =
                history.updatePaidAmount(receiptPaidAmount: receipt.paidAmount);
            //minus from customer debt the paid amount.
            customer = customer.debtDeduction(deductAmount: paidAmount);
            await provider.updatePaymentSubmission(
              receipt: receipt,
              customer: customer,
              history: history,
            );
            emit(ReceiptStateReceiptView(
                customer: customer,
                customerHistory: history,
                receipt: receipt));
          }
        }
      },
    );

    on<ReceiptEventPaymentDetailAcquisition>(
      (event, emit) {
        emit(const ReceiptStateLoading());
        emit(
          ReceiptStatePaymentDetailsAcquitision(
            customer: event.customer,
            customerHistory: event.customerHistory,
          ),
        );
      },
    );
  }
}
