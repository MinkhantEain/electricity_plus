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
  @override
  List<Object> get props => [super.props, userInput, pageName];
}

class CustomerSearchEditCustomerSearchInitialise extends CustomerSearchEvent {
  const CustomerSearchEditCustomerSearchInitialise();
}

class CustomerSearchMeterReadSearchInitialise extends CustomerSearchEvent {
  const CustomerSearchMeterReadSearchInitialise();
}

class CustomerSearchBillHistorySearchInitialise extends CustomerSearchEvent {
  const CustomerSearchBillHistorySearchInitialise();
}

class CustomerSearchExchangeMeterSearchInitialise extends CustomerSearchEvent {
  const CustomerSearchExchangeMeterSearchInitialise();
}




