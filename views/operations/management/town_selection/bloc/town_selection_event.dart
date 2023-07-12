part of 'town_selection_bloc.dart';

abstract class TownSelectionEvent extends Equatable {
  const TownSelectionEvent();
}

class TownSelectionAdd extends TownSelectionEvent {
  final String townName;
  const TownSelectionAdd({
    required this.townName,
  });
  @override
  List<Object?> get props => [townName];
}

class TownSelectionDeleteSelect extends TownSelectionEvent {
  final String townName;
  const TownSelectionDeleteSelect({
    required this.townName,
  });
  @override
  List<Object?> get props => [townName];
}

class TownSelectionDelete extends TownSelectionEvent {
  final String townName;
  const TownSelectionDelete({
    required this.townName,
  });
  @override
  List<Object?> get props => [townName];
}

class TownSelectionSelected extends TownSelectionEvent {
  final String townName;
  const TownSelectionSelected({
    required this.townName,
  });
  @override
  List<Object?> get props => [townName];
}