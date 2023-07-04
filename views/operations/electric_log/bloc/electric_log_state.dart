part of 'electric_log_bloc.dart';

abstract class ElectricLogState extends Equatable {
  const ElectricLogState();
  
  @override
  List<Object> get props => [];
}

class ElectricLogForm extends ElectricLogState {
  final CloudCustomer customer;
  final String previousReading;
  const ElectricLogForm({required this.customer, required this.previousReading});
}

class ElectricLogError extends ElectricLogState {
  const ElectricLogError();
}

class ElectricLogLoading extends ElectricLogState {
  const ElectricLogLoading();
}

class ElectricLogSubmitted extends ElectricLogState {
  final CloudCustomerHistory history;
  final CloudCustomer customer;
  const ElectricLogSubmitted({required this.customer, required this.history});
}


class ELectricLogErrorInvalidInput extends ElectricLogError {
  final String invalidInput;
  const ELectricLogErrorInvalidInput({required this.invalidInput});
}

class ELectricLogErrorEmptyInput extends ElectricLogError {
  const ELectricLogErrorEmptyInput();
}


class ELectricLogErrorUnableToUpdate extends ElectricLogError {
  const ELectricLogErrorUnableToUpdate();
}

class ElectricLogErrorUnableToUpload extends ElectricLogError {
  const ElectricLogErrorUnableToUpload();
}

class ELectricLogFormNextPage extends ElectricLogState {
  final CloudCustomer customer;
  final num newReading;
  const ELectricLogFormNextPage({required this.newReading, required this.customer});
}