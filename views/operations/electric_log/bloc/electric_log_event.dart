part of 'electric_log_bloc.dart';

abstract class ElectricLogEvent extends Equatable {
  const ElectricLogEvent();

  @override
  List<Object> get props => [];
}

class ElectricLogInitialise extends ElectricLogEvent {
  const ElectricLogInitialise();
}

class ElectricLogNextPage extends ElectricLogEvent {
  final CloudCustomer customer;
  final String newReading;
  const ElectricLogNextPage({required this.newReading,required this.customer});
}

class ElectricLogClickedBackOnNextPage extends ElectricLogEvent {
  const ElectricLogClickedBackOnNextPage();
}

class ElectricLogSubmission extends ElectricLogEvent {
  final CloudCustomer customer;
  final File image;
  final String comment;
  final bool flag;
  final num newReading;
  const ElectricLogSubmission({
    required this.customer,
    required this.image,
    required this.comment,
    required this.flag,
    required this.newReading,
  });
}