part of 'add_customer_bloc.dart';

abstract class AddCustomerEvent extends Equatable {
  const AddCustomerEvent();

  @override
  List<Object> get props => [];
}

class AddCustomerEventSubmission extends AddCustomerEvent{
  final String meterId;
  final String address;
  final String name;
  final String bookId;
  final String meterReading;
  final String horsePowerUnits;
  final String meterMultiplier;
  final bool hasRoadLight;
  const AddCustomerEventSubmission({
    required this.address,
    required this.bookId,
    required this.meterId,
    required this.meterReading,
    required this.name,
    required this.horsePowerUnits,
    required this.meterMultiplier,
    required this.hasRoadLight,
  });
}
