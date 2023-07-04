part of 'customer_search_bloc.dart';

abstract class CustomerSearchEvent extends Equatable {
  const CustomerSearchEvent();

  @override
  List<Object> get props => [];
}

class CustomerSearch extends CustomerSearchEvent {
  final String userInput;
  const CustomerSearch({required this.userInput});
}

class CustomerSearchReset extends CustomerSearchEvent {
  const CustomerSearchReset();
}

class CustomerSearchCustomerSelectedEvent extends CustomerSearchEvent {
  final CloudCustomer customer;
  const CustomerSearchCustomerSelectedEvent({required this.customer});
}