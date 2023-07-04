import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:equatable/equatable.dart';

part 'add_customer_event.dart';
part 'add_customer_state.dart';

class AddCustomerBloc extends Bloc<AddCustomerEvent, AddCustomerState> {
  AddCustomerBloc(FirebaseCloudStorage provider)
      : super(const AddCustomerInitialState()) {
    on<AddCustomerEventSubmission>((event, emit) async {
      //loads on submission
      emit(const AddCustomerStateLoading());
      if (event.address.isEmpty ||
          event.bookId.isEmpty ||
          event.meterId.isEmpty ||
          event.meterReading.isEmpty ||
          event.name.isEmpty ||
          event.meterMultiplier.isEmpty ||
          event.horsePowerUnits.isEmpty) {
        emit(const AddCustomerErrorStateEmptyInput());
      } else if (!isIntInput(event.meterReading)) {
        emit(AddCustomerErrorStateInvalidInput(
            field: 'Meter Reading', input: event.meterReading));
      } else if (!isIntInput(event.meterMultiplier) ||
          event.meterMultiplier == '0') {
        emit(AddCustomerErrorStateInvalidInput(
            field: 'Meter Multiplier', input: event.meterMultiplier));
      } else if (!isIntInput(event.horsePowerUnits)) {
        emit(AddCustomerErrorStateInvalidInput(
            field: 'HorsePower Units', input: event.horsePowerUnits));
      } else if (!isBookIdFormat(event.bookId)) {
        emit(AddCustomerErrorStateInvalidInput(
            field: 'BookID', input: event.bookId));
      } else {
        if (await provider.customerExists(bookId: event.bookId)) {
          emit(AddCustomerErrorStateAlreadyExists(bookId: event.bookId));
        } else {
          await provider.createUser(
              name: event.name,
              address: event.address,
              bookId: event.bookId,
              meterId: event.meterId,
              meterReading: num.parse(event.meterReading),
              meterMultiplier: num.parse(event.meterMultiplier),
              horsePowerUnits: num.parse(event.horsePowerUnits),
              hasRoadLight: event.hasRoadLight);
          emit(AddCustomerStateSubmitted(
              bookId: event.bookId, name: event.name));
        }
      }
    });
  }
}
