part of 'exchange_meter_bloc.dart';

abstract class ExchangeMeterState extends Equatable {
  const ExchangeMeterState();

  @override
  List<Object> get props => [];
}

class ExchangeMeterStateInitial extends ExchangeMeterState {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const ExchangeMeterStateInitial({
    required this.customer,
    required this.history,
  });
  @override
  List<Object> get props => [
        super.props,
        customer,
        history,
      ];
}

class ExchangeMeterStateLoading extends ExchangeMeterState {
  const ExchangeMeterStateLoading();
}

class ExchangeMeterStateSubmitted extends ExchangeMeterState {
  final CloudCustomer customer;
  final CloudCustomerHistory history;
  const ExchangeMeterStateSubmitted({
    required this.customer,
    required this.history,
  });
  @override
  List<Object> get props => [
        super.props,
        customer,
        history,
      ];
}
