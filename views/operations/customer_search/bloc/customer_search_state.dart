part of 'customer_search_bloc.dart';

abstract class CustomerSearchState extends Equatable {
  const CustomerSearchState();

  @override
  List<Object> get props => [];
}

class CustomerSearchInitial extends CustomerSearchState {
  final Iterable<CloudCustomer> customers;
  final ContextCallBack onTap;
  final String pageName;
  const CustomerSearchInitial(
      {required this.customers, required this.onTap, required this.pageName});
  @override
  List<Object> get props => [super.props, customers, onTap, pageName];
}

//meter read search selected
class CustomerSearchMeterReadSelected extends CustomerSearchState {
  final num previousUnit;
  final CloudCustomer customer;
  const CustomerSearchMeterReadSelected({
    required this.customer,
    required this.previousUnit,
  });
}

//bill history search
class CustomerSearchBillHistorySelected extends CustomerSearchState {
  final CloudCustomer customer;
  final Iterable<CloudCustomerHistory> historyList;
  const CustomerSearchBillHistorySelected({
    required this.customer,
    required this.historyList,
  });
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
  const CustomerSearchCustomerSelectedState({required this.customer});
}
