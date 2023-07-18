part of 'exchange_meter_bloc.dart';

abstract class ExchangeMeterEvent extends Equatable {
  const ExchangeMeterEvent();

  @override
  List<Object> get props => [];
}

class ExchangeMeterEventSubmit extends ExchangeMeterEvent {
  final String exchangeReason;
  final String previousUnit;
  final String newUnit;
  final String unitUsed;
  final String calculationDetails;
  final String cost;
  final String newMeterCost;
  final String newMeterId;
  final String initialMeterReading;
  final String totalCost;

  const ExchangeMeterEventSubmit({
    required this.calculationDetails,
    required this.cost,
    required this.exchangeReason,
    required this.initialMeterReading,
    required this.newMeterCost,
    required this.newMeterId,
    required this.newUnit,
    required this.previousUnit,
    required this.totalCost,
    required this.unitUsed,
  });

  @override
  List<Object> get props => [
        super.props,
        calculationDetails,
        cost,
        exchangeReason,
        initialMeterReading,
        newMeterCost,
        newMeterId,
        newUnit,
        previousUnit,
        totalCost,
        unitUsed,
      ];
}
