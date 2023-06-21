import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_exception.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev show log;

class OperationBloc extends Bloc<OperationEvent, OperationState> {
  OperationBloc(FirebaseCloudStorage provider)
      : super(const OperationStateUninitialised(isLoading: true)) {
    on<OperationEventDefault>(
      (event, emit) => emit(const OperationStateDefault()),
    );

    //customer receipt history implementation
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
              if (isBookIdFormat(userInput)) {
                customers = await provider.getCustomer(
                    bookId: userInput, meterNumber: null);
              } else {
                customers = await provider.getCustomer(
                    meterNumber: userInput, bookId: null);
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

    //flagged customer implementation
    on<OperationEventResolveIssue>(
      (event, emit) async {
        final customerHistory =
            await provider.getCustomerHistory(customer: event.customer);
        //coming to page
        if (!event.resolved) {
          emit(OperationStateResolveIssue(
            date: customerHistory.date,
            previousComment: customerHistory.comment,
            isLoading: false,
            customer: event.customer,
            exception: null,
            resolved: event.resolved,
          ));
        } else {
          Exception? exception;
          try {
            await provider.resolveIssue(
              customer: event.customer,
              comment: event.newComment,
            );
          } on CloudStorageException catch (e) {
            exception = e;
          }
          emit(OperationStateResolveIssue(
            date: customerHistory.date,
            previousComment: customerHistory.comment,
            isLoading: false,
            customer: event.customer,
            exception: exception,
            resolved: event.resolved,
          ));
        }
      },
    );

    on<OperationEventFlagCustomerSearch>(
      (event, emit) async {
        final allFlaggedCustomers = await provider.allFlaggedCustomer();
        if (!event.isSearching) {
          emit(
            OpeartionStateFlagCustomerSearch(
                exception: null,
                isLoading: false,
                customers: allFlaggedCustomers),
          );
        } else {
          if (event.userInput.isEmpty) {
            emit(OpeartionStateFlagCustomerSearch(
              exception: null,
              isLoading: false,
              customers: allFlaggedCustomers,
            ));
          } else {
            Exception? exception;
            String userInput = event.userInput;
            Iterable<CloudCustomer> customers;
            try {
              customers = await provider.searchFlaggedCustomer(
                userInput: userInput,
                customers: allFlaggedCustomers,
              );
            } on CouldNotGetCustomerException catch (e) {
              exception = e;
              customers = [];
            }
            emit(OpeartionStateFlagCustomerSearch(
              exception: exception,
              isLoading: false,
              customers: customers,
            ));
          }
        }
      },
    );

    //Customer electric log implementations
    on<OperationEventCreateNewElectricLog>(
      (event, emit) async {
        dev.log(event.newReading);
        //navigated to the page
        final lastUnit = await provider.getPreviousValidUnit(event.customer);
        if (event.newReading.isEmpty) {
          emit(OperationStateCreatingNewElectricLog(
            customer: event.customer,
            isLoading: false,
            exception: null,
            lastUnit: lastUnit,
          ));
        } else {
          //When next button is clicked
          final newReading = num.tryParse(event.newReading);
          Exception? exception;

          if (newReading == null) {
            //parse fail
            exception = UnableToParseException();
            emit(OperationStateCreatingNewElectricLog(
              customer: event.customer,
              isLoading: false,
              exception: exception,
              lastUnit: lastUnit,
            ));
          } else if (newReading < lastUnit) {
            //new unit is less than previous month's is invalid.
            exception = InvalidNewReadingException();
            emit(OperationStateCreatingNewElectricLog(
              customer: event.customer,
              isLoading: false,
              exception: exception,
              lastUnit: lastUnit,
            ));
          } else {
            //all is good.
            emit(OperationStateImageCommentFlag(
              customer: event.customer,
              isLoading: false,
              exception: null,
              newReading: newReading,
            ));
          }
        }
      },
    );

    on<OperationEventLogSubmission>(
      (event, emit) async {
        emit(OperationStateImageCommentFlag(
          customer: event.customer,
          isLoading: true,
          exception: null,
          newReading: event.newReading,
        ));
        Exception? exception;
        try {
          final imgUrl = await provider.storeImage(
            event.customer.documentId,
            event.image,
          );
          await provider.voidCurrentMonthHistory(customer: event.customer);
          await provider.submitElectricLog(
              customer: event.customer,
              newReading: event.newReading,
              comment: event.comment,
              imageUrl: imgUrl,
              flag: event.flag);
        } on CloudStorageException catch (e) {
          exception = e;
        }
        if (exception != null) {
          emit(OperationStateImageCommentFlag(
            customer: event.customer,
            isLoading: false,
            exception: exception,
            newReading: event.newReading,
          ));
        } else {
          emit(const OperationStateDefault());
        }
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
              if (isBookIdFormat(userInput)) {
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

    //set price implementation
    on<OperationEventSetPrice>(
      (event, emit) async {
        if (!event.isSettingPrice) {
          emit(OperationStateSettingPrice(
            exception: null,
            currentPrice: (await provider.getPrice).toString(),
            currentServiceCharge: (await provider.getServiceCharge).toString(),
            isLoading: false,
            currentHorsePowerPerUnitCost:
                (await provider.getHorsePowerPerUnitCost).toString(),
            currentRoadLightPrice:
                (await provider.getRoadLightPrice).toString(),
          ));
        } else {
          emit(OperationStateSettingPrice(
            exception: null,
            currentPrice: (await provider.getPrice).toString(),
            currentServiceCharge: (await provider.getServiceCharge).toString(),
            isLoading: true,
            currentHorsePowerPerUnitCost:
                (await provider.getHorsePowerPerUnitCost).toString(),
            currentRoadLightPrice:
                (await provider.getRoadLightPrice).toString(),
          ));
          Exception? exception;
          try {
            final price = event.price;
            final serviceCharge = event.serviceCharge;
            final horsePowerPerUnitCost = event.horsePowerPerUnitCost;
            final roadLightPrice = event.roadLightPrice;

            if (price.isNotEmpty) {
              await provider.setPrice(
                newPrice: price,
                token: event.tokenInput,
                priceChangeField: pricePerUnitField,
              );
            }
            if (serviceCharge.isNotEmpty) {
              await provider.setPrice(
                newPrice: serviceCharge,
                token: event.tokenInput,
                priceChangeField: serviceChargeField,
              );
            }
            if (horsePowerPerUnitCost.isNotEmpty) {
              await provider.setPrice(
                newPrice: horsePowerPerUnitCost,
                token: event.tokenInput,
                priceChangeField: horsePowerPerUnitCostField,
              );
            }

            if (roadLightPrice.isNotEmpty) {
              await provider.setPrice(
                newPrice: roadLightPrice,
                token: event.tokenInput,
                priceChangeField: roadLightPriceField,
              );
            }
          } on CloudStorageException catch (e) {
            dev.log((e is UnAuthorizedPriceSetException).toString());
            exception = e;
          }
          emit(OperationStateSettingPrice(
            exception: exception,
            currentPrice: (await provider.getPrice).toString(),
            currentServiceCharge: (await provider.getServiceCharge).toString(),
            isLoading: false,
            currentHorsePowerPerUnitCost:
                (await provider.getHorsePowerPerUnitCost).toString(),
            currentRoadLightPrice:
                (await provider.getRoadLightPrice).toString(),
          ));
        }
      },
    );

    //Add customer implementation
    on<OperationEventAddCustomer>(
      (event, emit) {
        //loading
        emit(const OperationStateAddCustomer(
            isLoading: true, isSubmitted: false, exception: null));

        if (event.hasRoadLight == null) {
          //gets to the page
          emit(const OperationStateAddCustomer(
              isLoading: false, isSubmitted: false, exception: null));
        } else {
          Exception? exception;
          try {
            if (event.address!.isEmpty ||
                event.bookId!.isEmpty ||
                event.meterId!.isEmpty ||
                event.meterReading!.isEmpty ||
                event.name!.isEmpty ||
                event.meterMultiplier!.isEmpty ||
                event.horsePowerUnits!.isEmpty ||
                (event.hasRoadLight == null)) {
              throw EmptyTextInputException();
            } else if (!isIntInput(event.meterReading!)) {
              throw InvalidMeterReadingException();
            } else if(!isIntInput(event.meterMultiplier!)) {
              throw InvalidMeterMultiplierException();
            } else if (!isIntInput(event.horsePowerUnits!)) {
              throw InvalidHorsePowerUnitException();
            } else if (!isBookIdFormat(event.bookId!)) {
              throw InvalidBookIdFormatException();
            } else {
              provider.createUser(
                name: event.name!,
                address: event.address!,
                bookId: event.bookId!,
                meterId: event.meterId!,
                meterReading: num.parse(event.meterReading!),
                meterMultiplier: num.parse(event.meterMultiplier!),
                horsePowerUnits: num.parse(event.horsePowerUnits!),
                hasRoadLight: event.hasRoadLight!
              );
            }
          } on Exception catch (e) {
            exception = e;
          }
          emit(OperationStateAddCustomer(
            isLoading: false,
            isSubmitted: true,
            exception: exception,
          ));
        }
      },
    );
  }
}
