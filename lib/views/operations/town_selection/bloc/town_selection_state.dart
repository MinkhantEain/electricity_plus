part of 'town_selection_bloc.dart';

abstract class TownSelectionState extends Equatable {
  const TownSelectionState();
}

class TownSelectionInitial extends TownSelectionState {
  const TownSelectionInitial();

  @override
  List<Object?> get props => [];
}

class TownSelectionStateTownAdded extends TownSelectionState {
  final String townName;
  @override
  List<Object?> get props => [];

  const TownSelectionStateTownAdded({required this.townName});
}

class TownSelectionStateDeleted extends TownSelectionState {
  final String townName;
  @override
  List<Object?> get props => [];
  const TownSelectionStateDeleted({required this.townName});
} 

class NewTownSelected extends TownSelectionState {
  final String newTownName;
  @override
  List<Object?> get props => [newTownName];
  const NewTownSelected({required this.newTownName});
}

class TownSelectionInitialised extends TownSelectionState {
  final Iterable<Town> towns;
  const TownSelectionInitialised({required this.towns});

  @override
  List<Object?> get props => [towns];
}

class TownSelectionError extends TownSelectionState {
  final String message;
  final Exception? exception;
  const TownSelectionError({required this.message, required this.exception});

  @override
  List<Object?> get props => [message, exception];
}

class TownSelectionLoading extends TownSelectionState {
  final String? loadingMessage;
  const TownSelectionLoading({required this.loadingMessage});

  @override
  List<Object?> get props => [loadingMessage];
}

class TownSelectionLoaded extends TownSelectionState {
  const TownSelectionLoaded();

  @override
  List<Object?> get props => [];
}
