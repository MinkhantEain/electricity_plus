part of 'customer_search_bloc.dart';

abstract class CustomerSearchEvent extends Equatable {
  const CustomerSearchEvent();

  @override
  List<Object> get props => [];
}

class CustomerSearchEventSearch extends CustomerSearchEvent {
  final String userInput;
  final ContextCallBack onTap;
  final String pageName;
  const CustomerSearchEventSearch({
    required this.userInput,
    required this.onTap,
    required this.pageName,
  });
}

class CustomerSearchMeterReadSearchInitialise extends CustomerSearchEvent {
  const CustomerSearchMeterReadSearchInitialise();
}

class CustomerSearchSelectMeterRead extends CustomerSearchEvent {
  final CloudCustomer customer;
  const CustomerSearchSelectMeterRead({required this.customer});
}

class CustomerSearchBillHistorySearchInitialise extends CustomerSearchEvent {
  const CustomerSearchBillHistorySearchInitialise();
}

class CustomerSearchSelectBillHistory extends CustomerSearchEvent {
  final CloudCustomer customer;
  const CustomerSearchSelectBillHistory({required this.customer});
}

class CustomerSearchCustomerSelectedEvent extends CustomerSearchEvent {
  final CloudCustomer customer;
  const CustomerSearchCustomerSelectedEvent({required this.customer});
}

class FLaggedCustomerListSearchEvent extends CustomerSearchEvent {
  const FLaggedCustomerListSearchEvent();
}
