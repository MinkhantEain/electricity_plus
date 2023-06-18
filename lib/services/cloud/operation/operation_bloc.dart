import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_exception.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev show log;

class OperationBloc extends Bloc<OperationEvent, OperationState> {
  OperationBloc(FirebaseCloudStorage provider)
      : super(const OperationStateUninitialised(isLoading: true)) {
    on<OperationEventDefault>(
      (event, emit) => emit(const OperationStateDefault()),
    );

    on<OperationEventLogSubmission>(
      (event, emit) async {
        Exception? exception;
        try {
          final imgUrl = await provider.storeImage(
            event.customer.documentId,
            event.image,
          );
          event.newHistory.set({
            commentField: event.comment,
            imageUrlField: imgUrl,
          });
         await provider.updateCustomerLastUnitAndFlag(
              documentId: event.customer.documentId,
              lastUnit: event.newReading,
              flag: event.flag);
        } on CloudStorageException catch (e) {
          exception = e;
        }
        if (exception != null) {
          emit(OperationStateImageCommentFlag(
            customer: event.customer,
            newHistory: event.newHistory,
            isLoading: false,
            exception: exception,
            newReading: event.newReading,
          ));
        } else {
          emit(const OperationStateDefault());
        }
      },
    );

    on<OperationEventFetchCustomerReceiptHistory>(
      (event, emit) async {
        emit(
          OperationStateFetchingCustomerReceiptHistory(
            isLoading: false,
            customerHistory:
                await provider.getCustomerAllHistory(customer: event.customer),
            customer: event.customer,
          ),
        );
      },
    );

    on<OperationEventCreateNewElectricLog>(
      (event, emit) async {
        dev.log(event.newReading);
        if (event.newReading.isEmpty) {
          emit(OperationStateCreatingNewElectricLog(
            customer: event.customer,
            isLoading: false,
            newHistory: null,
            exception: null,
          ));
        } else {
          DocumentReference? newHistory =
              provider.createHistoryDocument(event.customer);
          final newReading = num.tryParse(event.newReading);
          Exception? exception;
          if (newReading == null) {
            exception = UnableToParseException();
            newHistory.delete();
            newHistory = null;
            emit(OperationStateCreatingNewElectricLog(
              customer: event.customer,
              newHistory: newHistory,
              isLoading: false,
              exception: exception,
            ));
          } else if (newReading < event.customer.lastUnit) {
            exception = InvalidNewReadingException();
            newHistory.delete();
            newHistory = null;
            emit(OperationStateCreatingNewElectricLog(
              customer: event.customer,
              newHistory: newHistory,
              isLoading: false,
              exception: exception,
            ));
          } else {
            final price = await provider.getPrice;
            final serviceCharge = await provider.getServiceCharge;
            newHistory.set({
              previousUnitField: event.customer.lastUnit,
              newUnitField: newReading,
              priceAtmField: price,
              serviceChargeField: serviceCharge,
              isVoidedField: false,
              dateField: DateTime.now().toString(),
              costField: (newReading - event.customer.lastUnit) * price +
                  serviceCharge,
            });
            emit(OperationStateImageCommentFlag(
              customer: event.customer,
              newHistory: newHistory,
              isLoading: false,
              exception: null,
              newReading: newReading,
            ));
          }
        }

        //find a way to create a new cloud customer
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
        try {
          receiptDetails = await provider.printReceipt(
            customer: event.customer,
            history: event.customerHistory,
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

    on<OperationEventElectricLogSearch>(
      (event, emit) async {
        if (!event.isSearching) {
          emit(
            OperationStateElectricLogSearch(
                customerIterable: await provider.allCustomer(),
                exception: null,
                isLoading: false),
          );
        } else {
          if (event.userInput.isEmpty) {
            emit(OperationStateElectricLogSearch(
              exception: null,
              isLoading: false,
              customerIterable: await provider.allCustomer(),
            ));
          } else {
            Exception? exception;
            String userInput = event.userInput;
            Iterable<CloudCustomer> customers;
            try {
              if (userInput.length == 8 && userInput.contains('/')) {
                dev.log('bookid');
                customers = await provider.getCustomer(
                    bookId: userInput, meterNumber: null);
              } else {
                customers = await provider.getCustomer(
                    meterNumber: userInput, bookId: null);
                dev.log('meterid');
              }
            } on CouldNotGetCustomerException catch (e) {
              exception = e;
              customers = [];
            }
            emit(OperationStateElectricLogSearch(
              exception: exception,
              isLoading: false,
              customerIterable: customers,
            ));
          }
        }
      },
    );

    on<OperationEventCustomerReceiptSearch>(
      (event, emit) async {
        if (!event.isSearching) {
          emit(OperationStateSearchingCustomerReceipt(
            exception: null,
            isLoading: false,
            customerIterable: await provider.allCustomer(),
          ));
        } else {
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
            String userInput = event.userInput;
            Iterable<CloudCustomer> customers;
            try {
              if (userInput.length == 8 && userInput.contains('/')) {
                dev.log('bookid');
                customers = await provider.getCustomer(
                    bookId: userInput, meterNumber: null);
              } else {
                customers = await provider.getCustomer(
                    meterNumber: userInput, bookId: null);
                dev.log('meterid');
              }
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
        }
      },
    );
  }
}
