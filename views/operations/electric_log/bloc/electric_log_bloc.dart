import 'dart:developer' as dev show log;
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:equatable/equatable.dart';

part 'electric_log_event.dart';
part 'electric_log_state.dart';

class ElectricLogBloc extends Bloc<ElectricLogEvent, ElectricLogState> {
  ElectricLogBloc(FirebaseCloudStorage provider, CloudCustomer customer,
      String previousReading)
      : super(ElectricLogForm(
            customer: customer, previousReading: previousReading)) {
              
    on<ElectricLogNextPage>((event, emit) {
      dev.log(previousReading);
      emit(const ElectricLogLoading());
      final newReading = num.parse(event.newReading);
      if (isIntInput(event.newReading) && (newReading >= num.parse(previousReading))) {
        dev.log('next');
        emit(ELectricLogFormNextPage(
            newReading: newReading, customer: event.customer));
      } else {
        emit(ELectricLogErrorInvalidInput(invalidInput: event.newReading));
        emit(ElectricLogForm(
            customer: customer, previousReading: previousReading));
      }
    });

    on<ElectricLogClickedBackOnNextPage>(
      (event, emit) {
        emit(ElectricLogForm(
            customer: customer, previousReading: previousReading));
      },
    );

    on<ElectricLogSubmission>(
      (event, emit) async {
        emit(const ElectricLogLoading());
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
                  flag: event.flag,
                  previousReading: num.parse(previousReading));
          emit(ElectricLogSubmitted(
              customer: customer, history: customerHistory));
        } on CloudStorageException catch (e) {
          // UnableToUploadImageException
          if (e is UnableToUpdateException) {
            emit(const ELectricLogErrorUnableToUpdate());
          } else if (e is UnableToUpdateException) {
            // unabletoUpadateException
            emit(const ELectricLogErrorUnableToUpdate());
          } else {
            emit(const ElectricLogError());
          }
        }
      },
    );
  }
}
