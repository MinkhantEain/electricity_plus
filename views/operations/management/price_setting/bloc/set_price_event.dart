part of 'set_price_bloc.dart';

abstract class SetPriceEvent extends Equatable {
  const SetPriceEvent();

  @override
  List<Object> get props => [];
}

class SetPriceEventInitialise extends SetPriceEvent {
  const SetPriceEventInitialise();
}

class SetPriceEventSubmit extends SetPriceEvent {
  final String newPrice;
  final String serviceCharge;
  final String horsePowerPerUnitCost;
  final String roadLightPrice;
  final String password;

  const SetPriceEventSubmit(
      {required this.newPrice,
      required this.serviceCharge,
      required this.horsePowerPerUnitCost,
      required this.roadLightPrice,
      required this.password});
}
