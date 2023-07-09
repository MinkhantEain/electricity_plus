part of 'customer_search_bloc.dart';

abstract class CustomerSearchState extends Equatable {
  const CustomerSearchState();

  @override
  List<Object> get props => [];
}

class CustomerSearchInitial extends CustomerSearchState {
  final String pageName;
  const CustomerSearchInitial({required this.pageName});
  @override
  List<Object> get props => [super.props, pageName];
}

//meter read search selected
class CustomerSearchMeterReadSearchSuccessful extends CustomerSearchState {
  final num previousUnit;
  final CloudCustomer customer;
  const CustomerSearchMeterReadSearchSuccessful({
    required this.customer,
    required this.previousUnit,
  });

  @override
  List<Object> get props => [
        super.props,
        previousUnit,
        customer,
      ];
}

//Edit Customer search selected
class CustomerSearchEditCustomerSearchSuccessful extends CustomerSearchState {
  final CloudCustomer customer;
  const CustomerSearchEditCustomerSearchSuccessful({
    required this.customer,
  });

  @override
  List<Object> get props => [
        super.props,
        customer,
      ];
}

//bill history search
class CustomerSearchBillHistorySearchSuccessful extends CustomerSearchState {
  final CloudCustomer customer;
  final Iterable<CloudCustomerHistory> historyList;
  const CustomerSearchBillHistorySearchSuccessful({
    required this.customer,
    required this.historyList,
  });

  @override
  List<Object> get props => [super.props, customer, historyList];
}

class CustomerSearchLoading extends CustomerSearchState {
  const CustomerSearchLoading();
}

class CustomerSearchError extends CustomerSearchState {
  const CustomerSearchError();
}

class CustomerSearchNotFoundError extends CustomerSearchError {
  const CustomerSearchNotFoundError();
}
