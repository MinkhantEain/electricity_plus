part of 'import_data_bloc.dart';

abstract class ImportDataState extends Equatable {
  const ImportDataState();

  @override
  List<Object> get props => [];
}

class ImportDataStateInitial extends ImportDataState {
  const ImportDataStateInitial();
}

class ImportDataStateFileChosen extends ImportDataStateInitial {
  final PlatformFile file;
  @override
  List<Object> get props => [super.props, file];

  const ImportDataStateFileChosen({required this.file});
}

class ImportDataStateDateChosen extends ImportDataStateInitial {
  final String date;
  @override
  List<Object> get props => [super.props, date];

  const ImportDataStateDateChosen({required this.date});
}

class ImportDataStateReadyToSubmit extends ImportDataStateInitial {
  final String date;
  final PlatformFile file;
  @override
  List<Object> get props => [super.props, file, date];

  const ImportDataStateReadyToSubmit({required this.date, required this.file});
}

class ImportDataStateLoading extends ImportDataState {
  const ImportDataStateLoading();
}

class ImportDataStateError extends ImportDataState {
  const ImportDataStateError();
}

class ImportDataStateErrorFileNotChosenError extends ImportDataStateError {
  const ImportDataStateErrorFileNotChosenError();
}

class ImportDataStateChosenFileNotValidError extends ImportDataStateError {
  const ImportDataStateChosenFileNotValidError();
}

class ImportDataStateErrorDateNotChosenError extends ImportDataStateError {
  const ImportDataStateErrorDateNotChosenError();
}

class ImportDataStateDataImported extends ImportDataState {
  const ImportDataStateDataImported();

  @override
  List<Object> get props => [super.props];
}
