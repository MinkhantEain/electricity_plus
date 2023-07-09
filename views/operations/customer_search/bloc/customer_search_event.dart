part of 'customer_search_bloc.dart';

abstract class CustomerSearchEvent extends Equatable {
  const CustomerSearchEvent();

  @override
  List<Object> get props => [];
}

class CustomerSearchEventSearch extends CustomerSearchEvent {
  final String userInput;
  final String pageName;
  const CustomerSearchEventSearch({
    required this.userInput,
    required this.pageName,
  });
}

class CustomerSearchEditCustomerSearchInitialise extends CustomerSearchEvent {
  const CustomerSearchEditCustomerSearchInitialise();
}

class CustomerSearchEditCustomerSearch extends CustomerSearchEvent {
  final CloudCustomer customer;
  const CustomerSearchEditCustomerSearch({required this.customer});
  @override
  List<Object> get props => [super.props, customer];
}

class CustomerSearchMeterReadSearchInitialise extends CustomerSearchEvent {
  const CustomerSearchMeterReadSearchInitialise();
}

class CustomerSearchMeterReadSearch extends CustomerSearchEvent {
  final CloudCustomer customer;
  const CustomerSearchMeterReadSearch({required this.customer});
  @override
  List<Object> get props => [super.props, customer];
}

class CustomerSearchBillHistorySearchInitialise extends CustomerSearchEvent {
  const CustomerSearchBillHistorySearchInitialise();
}

class CustomerSearchBillHistorySearch extends CustomerSearchEvent {
  final CloudCustomer customer;
  const CustomerSearchBillHistorySearch({required this.customer});
  @override
  List<Object> get props => [super.props, customer];
}

class FLaggedCustomerListSearchEvent extends CustomerSearchEvent {
  const FLaggedCustomerListSearchEvent();
}
