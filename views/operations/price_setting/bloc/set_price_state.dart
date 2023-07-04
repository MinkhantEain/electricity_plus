part of 'set_price_bloc.dart';

abstract class SetPriceState extends Equatable {
  const SetPriceState();

  @override
  List<Object> get props => [];
}

class SetPriceStateUninitialised extends SetPriceState {
  const SetPriceStateUninitialised();
}

class SetPriceStateLoading extends SetPriceState {
  const SetPriceStateLoading();
}

abstract class SetPriceStateError extends SetPriceState {
  const SetPriceStateError();
}

class SetPriceStateInvalidPassowrd extends SetPriceStateError {
  const SetPriceStateInvalidPassowrd();
}

class SetPriceStateGeneralError extends SetPriceStateError {
  const SetPriceStateGeneralError();
}

class SetPriceStateInvalidValueError extends SetPriceStateError {
  const SetPriceStateInvalidValueError();
}

//initialised or after changes are made
class SetPriceStateLoaded extends SetPriceState {
  final num price;
  final num serviceCharge;
  final num horsePowerPerUnitCost;
  final num roadLightPrice;

  const SetPriceStateLoaded({
    required this.price,
    required this.horsePowerPerUnitCost,
    required this.roadLightPrice,
    required this.serviceCharge,
  });
  @override
  List<Object> get props => [
        super.props,
        price,
        horsePowerPerUnitCost,
        roadLightPrice,
        serviceCharge
      ];
}
