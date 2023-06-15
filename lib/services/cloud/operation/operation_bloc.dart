import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_exception.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OperationBloc extends Bloc<OperationEvent, OperationState> {
  OperationBloc(FirebaseCloudStorage provider)
      : super(const OperationStateUninitialised(isLoading: true)) {
    on<OperationEventDefault>(
      (event, emit) => emit(const OperationStateDefault()),
    );

    on<OperationEventSetPriceIntention>(
      (event, emit) {
        emit(const OperationStateSettingPrice(
          exception: null,
          price: '',
          isChanged: false,
        ));
      },
    );

    on<OperationEventSetPrice>(
      (event, emit) async {
        Exception? exception;
        bool isChanged;
        try {
          provider.setPrice(event.price, event.tokenInput);
          isChanged = true;
        } on CloudStorageException catch (e) {
          exception = e;
          isChanged = false;
        }
        emit(OperationStateSettingPrice(
          exception: exception,
          price: event.price,
          isChanged: isChanged,
        ));
      },
    );

    on<OperationEventReceiptGeneration>(
      (event, emit) async {
        emit(OperationStateGeneratingReceipt(
          receiptDetails:
              await provider.printReceipt(customer: event.customer!),
        ));
      },
    );

    on<OperationEventCustomerSearch>(
      (event, emit) async {
        emit(const OperationStateSearchingCustomer(
          cloudCustomers: [],
          exception: null,
          isLoading: false,
        ));

        if (!event.isSearching) {
          return;
        }

        emit(const OperationStateSearchingCustomer(
          exception: null,
          isLoading: true,
          cloudCustomers: [],
        ));

        final Exception? exception;
        final userInput = event.userInput;
        final Iterable<CloudCustomer> customers;
        if (userInput != null) {
          if (userInput.length == 6 && userInput.contains('/')) {
            customers = await provider.getCustomer(bookId: userInput);
          } else {
            customers = await provider.getCustomer(meterNumber: userInput);
          }
          exception = null;
          emit(OperationStateSearchingCustomer(
            exception: exception,
            isLoading: false,
            cloudCustomers: customers,
          ));
        } else {
          exception = InvalidSearchInputOperationException();
          emit(OperationStateSearchingCustomer(
            exception: exception,
            isLoading: false,
            cloudCustomers: const [],
          ));
        }
      },
    );
  }
}
