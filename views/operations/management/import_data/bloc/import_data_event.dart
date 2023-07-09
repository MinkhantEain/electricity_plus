part of 'import_data_bloc.dart';

abstract class ImportDataEvent extends Equatable {
  const ImportDataEvent();

  @override
  List<Object> get props => [];
}

class ImportDataEventReinitialisePage extends ImportDataEvent {
  const ImportDataEventReinitialisePage();
}

class ImportDataEventFileNotChosenSubmit extends ImportDataEvent {
  const ImportDataEventFileNotChosenSubmit();
}

class ImportDataEventChooseFile extends ImportDataEvent {
  const ImportDataEventChooseFile();
  @override
  List<Object> get props => [super.props];
}


class ImportDataEventSubmit extends ImportDataEvent {
  final String date;
  final PlatformFile file;
  const ImportDataEventSubmit({ required this.date, required this.file});

  @override
  List<Object> get props => [super.props, date, file];
}