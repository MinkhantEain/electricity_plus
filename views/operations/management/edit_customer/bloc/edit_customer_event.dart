part of 'edit_customer_bloc.dart';

abstract class EditCustomerEvent extends Equatable {
  const EditCustomerEvent();

  @override
  List<Object> get props => [];
}


class EditCustomerEventSubmit extends EditCustomerEvent {
  final String name;
  final String meterMultiplier;
  final String horsePowerUnits;
  final bool hasRoadLightCost;
  const EditCustomerEventSubmit({
    required this.name,
    required this.hasRoadLightCost,
    required this.horsePowerUnits,
    required this.meterMultiplier,
  });
  @override
  List<Object> get props => [
        super.props,
        name,
        meterMultiplier,
        horsePowerUnits,
        hasRoadLightCost,
      ];
}
