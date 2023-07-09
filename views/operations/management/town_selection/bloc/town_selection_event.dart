part of 'town_selection_bloc.dart';

abstract class TownSelectionEvent extends Equatable {
  const TownSelectionEvent();
}

class TownSelectionInitialise extends TownSelectionEvent {
  const TownSelectionInitialise();
  @override
  List<Object?> get props => [];

}

class TownSelectionAdd extends TownSelectionEvent {
  final String townName;
  const TownSelectionAdd({
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