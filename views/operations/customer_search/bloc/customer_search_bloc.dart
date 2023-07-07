import 'package:bloc/bloc.dart';
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

typedef CustomerCallBack = void Function(CloudCustomer customer);
typedef ContextCallBack = CustomerCallBack Function(BuildContext context);

class CustomerSearchBloc
    extends Bloc<CustomerSearchEvent, CustomerSearchState> {
  CustomerSearchBloc(FirebaseCloudStorage provider)
      : super(CustomerSearchInitial(
            customers: const [],
            onTap: (context) {
              return (customer) {};
            },
            pageName: '')) {
    on<CustomerSearchEventSearch>((event, emit) async {
      emit(const CustomerSearchLoading());
      if (event.userInput.isEmpty) {
        emit(CustomerSearchInitial(
          customers: const [],
          onTap: event.onTap,
          pageName: event.pageName,
        ));
      } else {
        try {
          if (isBookIdFormat(event.userInput)) {
            emit(CustomerSearchInitial(
              customers: await provider.getCustomer(
                  bookId: event.userInput, meterNumber: null),
              onTap: event.onTap,
              pageName: event.pageName,
            ));
          } else {
            emit(CustomerSearchInitial(
              customers: await provider.getCustomer(
                  bookId: null, meterNumber: event.userInput),
              onTap: event.onTap,
              pageName: event.pageName,
            ));
          }
        } on Exception {
          emit(const CustomerSearchError());
        }
      }
    });

    on<CustomerSearchBillHistorySearchInitialise>(
      (event, emit) {
        emit(const CustomerSearchLoading());
        emit(CustomerSearchInitial(
          customers: const [],
          onTap: (context) {
            return (customer) async {
              context
                  .read<CustomerSearchBloc>()
                  .add(CustomerSearchSelectBillHistory(customer: customer));
            };
          },
          pageName: 'Bill Search',
        ));
      },
    );

    on<CustomerSearchSelectBillHistory>(
      (event, emit) async {
        emit(const CustomerSearchLoading());
        emit(CustomerSearchBillHistorySelected(
            customer: event.customer,
            historyList: await provider.getCustomerAllHistory(
                customer: event.customer)));
      },
    );

    on<CustomerSearchMeterReadSearchInitialise>(
      (event, emit) {
        emit(const CustomerSearchLoading());
        emit(CustomerSearchInitial(
          customers: const [],
          onTap: (context) {
            return (customer) {
              context
                  .read<CustomerSearchBloc>()
                  .add(CustomerSearchSelectMeterRead(customer: customer));
            };
          },
          pageName: 'Meter Read',
        ));
      },
    );

    on<CustomerSearchSelectMeterRead>(
      (event, emit) async {
        emit(const CustomerSearchLoading());
        emit(CustomerSearchMeterReadSelected(
            customer: event.customer,
            previousUnit: await provider.getPreviousValidUnit(event.customer)));
      },
    );

    // on<FLaggedCustomerListSearchEvent>(
    //   (event, emit) async {
    //     emit(const CustomerSearchLoading());
    //     try {
    //       emit(CustomerSearchInitial(
    //           customers: await provider.allFlaggedCustomer()));
    //     } on Exception {
    //       emit(const CustomerSearchError());
    //     }
    //   },
    // );

    on<CustomerSearchCustomerSelectedEvent>(
      (event, emit) async {
        emit(CustomerSearchCustomerSelectedState(customer: event.customer));
      },
    );
  }
}
