part of 'read_meter_bloc.dart';

abstract class ReadMeterEvent extends Equatable {
  const ReadMeterEvent();

  @override
  List<Object> get props => [];
}

class ReadMeterEventSecondPage extends ReadMeterEvent {
  final CloudCustomer customer;
  final String newReading;
  const ReadMeterEventSecondPage({required this.newReading,required this.customer});
}

class ReadMeterEventClickedBackToFirstPage extends ReadMeterEvent {
  const ReadMeterEventClickedBackToFirstPage();
}

class ReadMeterEventFlagReport extends ReadMeterEvent {
  final CloudCustomer customer;
  const ReadMeterEventFlagReport({required this.customer});
}

class ReadMeterEventSubmission extends ReadMeterEvent {
  final CloudCustomer customer;
  final File image;
  final String comment;
  final num newReading;
  const ReadMeterEventSubmission({
    required this.customer,
    required this.image,
    required this.comment,
    required this.newReading,
  });
}

class ReadMeterEventSubmitFlagReport extends ReadMeterEvent {
  final File image;
  final String comment;
  const ReadMeterEventSubmitFlagReport({
    required this.comment,
    required this.image,
  });
}