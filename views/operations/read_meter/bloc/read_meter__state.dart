part of 'read_meter_bloc.dart';

abstract class ReadMeterState extends Equatable {
  const ReadMeterState();
  
  @override
  List<Object> get props => [];
}

class ReadMeterStateFirstPage extends ReadMeterState {
  final CloudCustomer customer;
  final String previousReading;
  const ReadMeterStateFirstPage({required this.customer, required this.previousReading});
}

class ReadMeterStateError extends ReadMeterState {
  const ReadMeterStateError();
}

class ReadMeterStateLoading extends ReadMeterState {
  const ReadMeterStateLoading();
}

class ReadMeterStateSubmitted extends ReadMeterState {
  final CloudCustomerHistory history;
  final CloudCustomer customer;
  const ReadMeterStateSubmitted({required this.customer, required this.history});
}


class ReadMeterStateErrorInvalidInput extends ReadMeterStateError {
  final String invalidInput;
  const ReadMeterStateErrorInvalidInput({required this.invalidInput});
}

class ReadMeterStateErrorEmptyInput extends ReadMeterStateError {
  const ReadMeterStateErrorEmptyInput();
}


class ReadMeterStateErrorUnableToUpdate extends ReadMeterStateError {
  const ReadMeterStateErrorUnableToUpdate();
}

class ReadMeterStateErrorUnableToUpload extends ReadMeterStateError {
  const ReadMeterStateErrorUnableToUpload();
}

class ReadMeterStateFlagReportSubmitted extends ReadMeterState {
  const ReadMeterStateFlagReportSubmitted();
}

class ReadMeterStateSecondPage extends ReadMeterState {
  final CloudCustomer customer;
  final num newReading;
  const ReadMeterStateSecondPage({required this.newReading, required this.customer});
}

class ReadMeterStateFlagReport extends ReadMeterState {
  final CloudCustomer customer;
  const ReadMeterStateFlagReport({required this.customer});
}