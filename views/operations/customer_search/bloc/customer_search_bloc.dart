import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:equatable/equatable.dart';

part 'customer_search_event.dart';
part 'customer_search_state.dart';

class CustomerSearchBloc
    extends Bloc<CustomerSearchEvent, CustomerSearchState> {
  CustomerSearchBloc(FirebaseCloudStorage provider)
      : super(const CustomerSearchInitial(customers: [])) {

    on<CustomerSearch>((event, emit) async {
      emit(const CustomerSearchLoading());
      if (event.userInput.isEmpty) {
        emit(const CustomerSearchInitial(customers: []));
      } else {
        try {
          if (isBookIdFormat(event.userInput)) {
            emit(CustomerSearchInitial(
                customers: await provider.getCustomer(
                    bookId: event.userInput, meterNumber: null)));
          } else {
            emit(CustomerSearchInitial(
                customers: await provider.getCustomer(
                    bookId: null, meterNumber: event.userInput)));
          }
        } on Exception {
          emit(const CustomerSearchError());
        }
      }
    });

    on<CustomerSearchReset>(
      (event, emit) {
        emit(const CustomerSearchInitial(customers: []));
      },
    );

    on<CustomerSearchCustomerSelectedEvent>((event, emit) async {
      final previousReading = await provider.getPreviousValidUnit(event.customer);
      emit(CustomerSearchCustomerSelectedState(customer: event.customer, previousReading: previousReading.toString()));
    },);
  }
}
