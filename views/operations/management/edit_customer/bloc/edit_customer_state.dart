part of 'edit_customer_bloc.dart';

abstract class EditCustomerState extends Equatable {
  const EditCustomerState();

  @override
  List<Object> get props => [];
}

class EditCustomerInitial extends EditCustomerState {
  final CloudCustomer customer;
  const EditCustomerInitial({
    required this.customer,
  });
  @override
  List<Object> get props => [super.props, customer];
}


class EditCustomerStateLoading extends EditCustomerState {
  const EditCustomerStateLoading();
}

class EditCustomerStateSubmitted extends EditCustomerState {
  const EditCustomerStateSubmitted();
}