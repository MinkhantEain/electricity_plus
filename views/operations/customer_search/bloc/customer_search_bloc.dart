import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'customer_search_event.dart';
part 'customer_search_state.dart';

class CustomerSearchBloc
    extends Bloc<CustomerSearchEvent, CustomerSearchState> {
  CustomerSearchBloc(FirebaseCloudStorage provider)
      : super(const CustomerSearchInitial(pageName: '')) {

    on<CustomerSearchEventSearch>((event, emit) async {
      emit(const CustomerSearchLoading());
      if (event.userInput.isEmpty) {
        emit(CustomerSearchInitial(
          pageName: event.pageName,
        ));
      } else {
        try {
          if (isBookIdFormat(event.userInput)) {
            final customer =
                await provider.getCustomer(bookId: event.userInput);
            if (event.pageName == 'Bill Search') {
              emit(CustomerSearchBillHistorySearchSuccessful(
                  customer: customer,
                  historyList:
                      await provider.getRecentBillHistory(customer: customer)));
            } else if (event.pageName == 'Meter Read') {
              emit(CustomerSearchMeterReadSearchSuccessful(
                  customer: customer,
                  previousUnit: await provider.getPreviousValidUnit(customer)));
            } else if (event.pageName == 'Edit Customer') {
              emit(CustomerSearchEditCustomerSearchSuccessful(customer: customer));
            } else {
              emit(CustomerSearchInitial(pageName: event.pageName));
            }
          } else {
            throw NoSuchDocumentException();
          }
        } on NoSuchDocumentException {
          emit(const CustomerSearchNotFoundError());
          emit(CustomerSearchInitial(pageName: event.pageName));
        }
      }
    });


    //initialising
    on<CustomerSearchBillHistorySearchInitialise>(
      (event, emit) {
        emit(const CustomerSearchLoading());
        emit(const CustomerSearchInitial(
          pageName: 'Bill Search',
        ));
      },
    );

    on<CustomerSearchEditCustomerSearchInitialise>(
      (event, emit) {
        emit(const CustomerSearchLoading());
        emit(const CustomerSearchInitial(
          pageName: 'Edit Customer',
        ));
      },
    );

    on<CustomerSearchMeterReadSearchInitialise>(
      (event, emit) {
        emit(const CustomerSearchLoading());
        emit(const CustomerSearchInitial(
          pageName: 'Meter Read',
        ));
      },
    );
  }
}
