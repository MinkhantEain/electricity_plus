part of 'customer_search_bloc.dart';

abstract class CustomerSearchState extends Equatable {
  const CustomerSearchState();
  
  @override
  List<Object> get props => [];
}

class CustomerSearchInitial extends CustomerSearchState {
  final Iterable<CloudCustomer> customers;
  const CustomerSearchInitial({required this.customers});
  @override
  List<Object> get props => [super.props, customers];
}

class CustomerSearchLoading extends CustomerSearchState {
  const CustomerSearchLoading();
}

class CustomerSearchError extends CustomerSearchState {
  const CustomerSearchError();
}

class CustomerSearchNoUserError extends CustomerSearchError {
  const CustomerSearchNoUserError();
}

class CustomerSearchCustomerSelectedState extends CustomerSearchState {
  final CloudCustomer customer;
  final String previousReading;
  const CustomerSearchCustomerSelectedState({required this.customer, required this.previousReading});
}

