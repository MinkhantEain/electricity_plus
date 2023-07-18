import 'dart:developer' as dev show log;
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'read_meter_event.dart';
part 'read_meter__state.dart';

class ReadMeterBloc extends Bloc<ReadMeterEvent, ReadMeterState> {
  ReadMeterBloc(FirebaseCloudStorage provider, CloudCustomer customer,
      String previousReading)
      : super(ReadMeterStateFirstPage(
            customer: customer, previousReading: previousReading)) {
    on<ReadMeterEventSecondPage>((event, emit) {
      dev.log(previousReading);
      emit(const ReadMeterStateLoading());
      final newReading = num.parse(event.newReading);
      if (isIntInput(event.newReading) &&
          (newReading >= num.parse(previousReading))) {
        dev.log('next');
        emit(ReadMeterStateSecondPage(
            newReading: newReading, customer: event.customer));
      } else {
        emit(ReadMeterStateErrorInvalidInput(invalidInput: event.newReading));
        emit(ReadMeterStateFirstPage(
            customer: customer, previousReading: previousReading));
      }
    });

    on<ReadMeterEventClickedBackToFirstPage>(
      (event, emit) {
        emit(ReadMeterStateFirstPage(
            customer: customer, previousReading: previousReading));
      },
    );

    on<ReadMeterEventSubmission>(
      (event, emit) async {
        emit(const ReadMeterStateLoading());
        try {
          final imgUrl = await provider.storeImage(
            event.customer.documentId,
            event.image,
          );
          await provider.voidCurrentMonthLastHistory(customer: event.customer);
          CloudCustomerHistory customerHistory =
              await provider.submitElectricLog(
            customer: event.customer,
            newReading: event.newReading,
            comment: event.comment,
            imageUrl: imgUrl,
            previousReading: num.parse(previousReading),
          );
          final updatedCustomer = await provider.getCustomer(bookId: customer.bookId);
          final historyList = await provider.getRecentBillHistory(customer: updatedCustomer);
          emit(ReadMeterStateSubmitted(
            customer: updatedCustomer,
            history: customerHistory,
            historyList: historyList,
          ));
        } on CloudStorageException catch (e) {
          // UnableToUploadImageException
          if (e is UnableToUploadImageException) {
            emit(const ReadMeterStateErrorUnableToUpload());
          } else if (e is UnableToUpdateException) {
            // unabletoUpadateException
            emit(const ReadMeterStateErrorUnableToUpdate());
          } else {
            emit(const ReadMeterStateError());
          }
        }
      },
    );

    on<ReadMeterEventFlagReport>(
      (event, emit) {
        emit(const ReadMeterStateLoading());
        emit(ReadMeterStateFlagReport(customer: event.customer));
      },
    );

    on<ReadMeterEventSubmitFlagReport>(
      (event, emit) async {
        emit(const ReadMeterStateLoading());
        try {
          final imgUrl = await provider
              .storeImage(customer.documentId, event.image, fileName: 'flag');
          await provider.voidCurrentMonthLastHistory(customer: customer);
          await provider.submitFlagReport(
            customer: customer,
            comment: event.comment,
            imageUrl: imgUrl,
            inspector: FirebaseAuth.instance.currentUser!.displayName!,
          );
          emit(const ReadMeterStateFlagReportSubmitted());
        } on CloudStorageException catch (e) {
          // UnableToUploadImageException
          if (e is UnableToUploadImageException) {
            emit(const ReadMeterStateErrorUnableToUpload());
          } else if (e is UnableToUpdateException) {
            // unabletoUpadateException
            emit(const ReadMeterStateErrorUnableToUpdate());
          } else {
            emit(const ReadMeterStateError());
          }
        }
      },
    );
  }
}
