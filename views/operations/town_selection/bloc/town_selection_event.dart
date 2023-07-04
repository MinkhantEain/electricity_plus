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
  final String password;
  const TownSelectionAdd({
    required this.townName,
    required this.password,
  });
  @override
  List<Object?> get props => [townName, password];
}

class TownSelectionDelete extends TownSelectionEvent {
  final String townName;
  final String password;
  const TownSelectionDelete({
    required this.townName,
    required this.password,
  });
  @override
  List<Object?> get props => [townName, password];
}

class TownSelectionSelected extends TownSelectionEvent {
  final String townName;
  final String password;
  const TownSelectionSelected({
    required this.townName,
    required this.password,
  });
  @override
  List<Object?> get props => [townName, password];
}