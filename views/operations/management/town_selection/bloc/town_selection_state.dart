part of 'town_selection_bloc.dart';

abstract class TownSelectionState extends Equatable {
  final Iterable<Town> towns;
  const TownSelectionState({required this.towns});

  @override
  List<Object?> get props => [towns];
}

class TownSelectionInitial extends TownSelectionState {
  const TownSelectionInitial({required Iterable<Town> towns})
      : super(towns: towns);

  @override
  List<Object?> get props => [super.props];
}

class TownSelectionStateTownAdded extends TownSelectionState {
  final String townName;
  const TownSelectionStateTownAdded(
      {required Iterable<Town> towns, required this.townName})
      : super(towns: towns);

  @override
  List<Object?> get props => [super.props, townName];
}

class TownSelectionStateDeleted extends TownSelectionState {
  final String townName;
  const TownSelectionStateDeleted(
      {required Iterable<Town> towns, required this.townName})
      : super(towns: towns);

  @override
  List<Object?> get props => [super.props, townName];
}

class TownSelectionStateDeleteSelected extends TownSelectionState {
  final String townName;
  const TownSelectionStateDeleteSelected(
      {required Iterable<Town> towns, required this.townName})
      : super(towns: towns);

  @override
  List<Object?> get props => [super.props, townName];
}

class NewTownSelected extends TownSelectionState {
  final String newTownName;
  const NewTownSelected(
      {required Iterable<Town> towns, required this.newTownName})
      : super(towns: towns);

  @override
  List<Object?> get props => [super.props, newTownName];
}

class TownSelectionError extends TownSelectionState {
  final String message;
  final Exception? exception;
  const TownSelectionError(
      {required Iterable<Town> towns, required this.message, required this.exception})
      : super(towns: towns);

  @override
  List<Object?> get props => [super.props, exception, message];
}

class TownSelectionLoading extends TownSelectionState {
  final String? loadingMessage;
  const TownSelectionLoading({required Iterable<Town> towns , required this.loadingMessage})
      : super(towns: towns);

  @override
  List<Object?> get props => [super.props, loadingMessage];
}

class TownSelectionLoaded extends TownSelectionState {
  const TownSelectionLoaded({required Iterable<Town> towns})
      : super(towns: towns);

  @override
  List<Object?> get props => [super.props];
}

class TownSelectionEmptyTownNameInput extends TownSelectionState {
  const TownSelectionEmptyTownNameInput({required Iterable<Town> towns})
      : super(towns: towns);

  @override
  List<Object?> get props => [super.props];
}
