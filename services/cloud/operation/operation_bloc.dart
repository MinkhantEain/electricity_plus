import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_exception.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/services/others/excel_production.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OperationBloc extends Bloc<OperationEvent, OperationState> {
  OperationBloc(FirebaseCloudStorage provider)
      : super(const OperationStateUninitialised(isLoading: true)) {
    on<OperationEventDefault>((event, emit) async {
      emit(
          OperationStateDefault(townName: await AppDocumentData.getTownName(), staff: await AppDocumentData.getUserDetails()));
    });

    on<OperationEventPayment>(
      (event, emit) {
        emit(OperationStatePayment(qrCode: event.qrCode));
      },
    );

    on<OperationEventAppUser>((event, emit) => emit(const OperationStateAppUser()),);

    //customer receipt history implementation
    on<OperationEventFetchCustomerHistory>(
      (event, emit) async {
        emit(
          OperationStateFetchingCustomerHistory(
            isLoading: false,
            customerHistory:
                await provider.getCustomerAllHistory(customer: event.customer),
            customer: event.customer,
          ),
        );
      },
    );

    on<OperationEventBillGeneration>((event, emit) async {
      emit(OperationStateGeneratingBill(
          customer: event.customer, history: event.customerHistory));
    });

    on<OperationEventBillHistory>(
      (event, emit) {
        emit(const OperationStateBillHistory());
      },
    );

    // on<OperationEventCustomerHistorySearch>(
    //   (event, emit) async {
    //     if (!event.isSearching) {
    //       emit(const OperationStateSearchingCustomerHistory(
    //         exception: null,
    //         isLoading: false,
    //         customerIterable: [],
    //       ));
    //     } else {
    //       //no user input
    //       if (event.userInput.isEmpty) {
    //         emit(const OperationStateSearchingCustomerHistory(
    //           exception: null,
    //           isLoading: false,
    //           customerIterable: [],
    //         ));
    //       } else {
    //         //has user input
    //         Exception? exception;
    //         String userInput = event.userInput;
    //         Iterable<CloudCustomer> customers;
    //         try {
    //           if (isBookIdFormat(userInput)) {
    //             customers = await provider.getCustomer(
    //                 bookId: userInput, meterNumber: null);
    //           } else {
    //             customers = await provider.getCustomer(
    //                 meterNumber: userInput, bookId: null);
    //           }
    //         } on CouldNotGetCustomerException catch (e) {
    //           exception = e;
    //           customers = [];
    //         }
    //         emit(OperationStateSearchingCustomerHistory(
    //           exception: exception,
    //           isLoading: false,
    //           customerIterable: customers,
    //         ));
    //       }
    //     }
    //   },
    // );

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
            await provider.resolveRedFlag(
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

    on<OperationEventFlagged>(
      (event, emit) {
        emit(const OperationStateFlagged());
      },
    );

    on<OperationEventElectricLog>(
      (event, emit) async {
        emit(const OperationStateElectricLogSearch());
      },
    );

    //set price implementation
    on<OperationEventSetPrice>(
      (event, emit) async {
        emit(const OperationStateSettingPrice(
          exception: null,
          currentPrice: '',
          currentServiceCharge: '',
          isLoading: true,
          currentHorsePowerPerUnitCost: '',
          currentRoadLightPrice: '',
        ));
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
        emit(const OperationStateAddCustomer());
      },
    );

    //AdminView
    on<OperationEventAdminView>(
      (event, emit) {
        emit(const OperationStateAdminView(
          isLoading: false,
          exception: null,
        ));
      },
    );

    //import data implementation
    on<OperationEventInitialiseData>(
      (event, emit) async {
        emit(const OperationStateInitialiseData());
      },
    );

    

    on<OperationEventChooseTown>(
      (event, emit) async {
        final towns = await provider.getAllTown();
        emit(OperationStateChooseTown(
          isLoading: true,
          towns: towns,
          exception: null,
        ));
        emit(OperationStateChooseTown(
          isLoading: false,
          towns: towns,
          exception: null,
        ));
      },
    );

    on<OperationEventProduceExcel>(
      (event, emit) async {
        emit(const OperationStateProduceExcel(
          isLoading: true,
          exception: null,
        ));

        await createExcelSheet(await AppDocumentData.getTownName());
        emit(const OperationStateProduceExcel(
          isLoading: false,
          exception: null,
        ));
      },
    );

    on<OperationEventChooseBluetooth>(
      (event, emit) {
        emit(const OperationStateChooseBluetooth(isLoading: false));
      },
    );
  }
}
