part of 'add_customer_bloc.dart';

abstract class AddCustomerState extends Equatable {
  const AddCustomerState();
  
  @override
  List<Object> get props => [];
}

class AddCustomerInitialState extends AddCustomerState {
  const AddCustomerInitialState();
}

class AddCustomerStateLoading extends AddCustomerState {
  const AddCustomerStateLoading();
}

class AddCustomerStateSubmitted extends AddCustomerState {
  final String name;
  final String bookId;
  const AddCustomerStateSubmitted({required this.name, required this.bookId});
}

class AddCustomerErrorState extends AddCustomerState {
  const AddCustomerErrorState();
}

class AddCustomerErrorStateEmptyInput extends AddCustomerErrorState {
  const AddCustomerErrorStateEmptyInput();
}

class AddCustomerErrorStateAlreadyExists extends AddCustomerErrorState {
  final String bookId;
  const AddCustomerErrorStateAlreadyExists({required this.bookId});
}

class AddCustomerErrorStateInvalidInput extends AddCustomerErrorState {
  final String field;
  final String input;
  const AddCustomerErrorStateInvalidInput({required this.field, required this.input});
}