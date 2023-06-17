import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/cloud_customer_history.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev show log;

class OperationBloc extends Bloc<OperationEvent, OperationState> {
  OperationBloc(FirebaseCloudStorage provider)
      : super(const OperationStateUninitialised(isLoading: true)) {
    on<OperationEventDefault>(
      (event, emit) => emit(const OperationStateDefault()),
    );

    on<OperationEventFetchCustomerReceiptHistory>(
      (event, emit) async {
        emit(
          OperationStateFetchingCustomerReceiptHistory(
            isLoading: false,
            customerHistory: await provider.getCustomerAllHistory(customer: event.customer),
            customer: event.customer,
          ),
        );
      },
    );

    on<OperationEventSetPriceIntention>(
      (event, emit) async {
        emit(OperationStateSettingPrice(
          exception: null,
          isChanged: false,
          currentPrice: (await provider.getPrice).toString(),
          currentServiceCharge: (await provider.getServiceCharge).toString(),
        ));
      },
    );

    on<OperationEventSetPrice>(
      (event, emit) async {
        Exception? exception;
        bool isChanged;
        try {
          final price = event.price;
          final serviceCharge = event.serviceCharge;
          isChanged = false;
          if (price.isNotEmpty) {
            provider.setPrice(price, event.tokenInput);
            isChanged = true;
          }
          if (serviceCharge.isNotEmpty) {
            provider.setServiceCharge(serviceCharge, event.tokenInput);
            isChanged = true;
          }
        } on CloudStorageException catch (e) {
          exception = e;
          isChanged = false;
        }
        emit(OperationStateSettingPrice(
          exception: exception,
          isChanged: isChanged,
          currentPrice: (await provider.getPrice).toString(),
          currentServiceCharge: (await provider.getServiceCharge).toString(),
        ));
      },
    );

    on<OperationEventReceiptGeneration>(
      (event, emit) async {
        Exception? exception;
        String receiptDetails = 'Nothing to show';
        CloudCustomerHistory history =
            await provider.getCustomerHistory(customer: event.customer);
        try {
          receiptDetails = await provider.printReceipt(
            customer: event.customer,
            history: history,
          );
        } on CloudStorageException catch (e) {
          exception = e;
        }

        emit(OperationStateGeneratingReceipt(
          receiptDetails: receiptDetails,
          exception: exception,
        ));
      },
    );

    on<OperationEventCustomerReceiptSearch>(
      (event, emit) async {
        emit(OperationStateSearchingCustomerReceipt(
          exception: null,
          isLoading: false,
          customerIterable: await provider.allCustomer(),
        ));

        // if (!event.isSearching) {
        //   return;
        // }

        //no user input
        if (event.userInput.isEmpty) {
          emit(OperationStateSearchingCustomerReceipt(
            exception: null,
            isLoading: false,
            customerIterable: await provider.allCustomer(),
          ));
        } else {
          //has user input
          Exception? exception;
          String? userInput = event.userInput;
          Iterable<CloudCustomer> customers;
          try {
            if (userInput.isNotEmpty) {
              if (userInput.length == 8 && userInput.contains('/')) {
                dev.log('bookid');
                customers = await provider.getCustomer(
                    bookId: userInput, meterNumber: null);
              } else {
                customers = await provider.getCustomer(
                    meterNumber: userInput, bookId: null);
                dev.log('meterid');
              }
            } else {
              dev.log('error thrown');
              throw CouldNotGetCustomerException();
            }
            // customers = await provider.getCustomer(
            //     bookId: null, meterNumber: userInput);
          } on CouldNotGetCustomerException catch (e) {
            exception = e;
            customers = [];
          }
          emit(OperationStateSearchingCustomerReceipt(
            exception: exception,
            isLoading: false,
            customerIterable: customers,
          ));
        }
      },
    );
  }
}
