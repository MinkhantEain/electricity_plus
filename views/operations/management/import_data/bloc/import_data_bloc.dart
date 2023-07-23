import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:developer' as dev show log;

part 'import_data_event.dart';
part 'import_data_state.dart';

class ImportDataBloc extends Bloc<ImportDataEvent, ImportDataState> {
  ImportDataBloc(FirebaseCloudStorage provider)
      : super(const ImportDataStateInitial()) {
    on<ImportDataEventChooseFile>(
      (event, emit) async {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          withData: false,
          allowMultiple: false,
        );
        if (result != null) {
          if (result.files.first.extension! != 'csv') {
            emit(const ImportDataStateChosenFileNotValidError());
            emit(const ImportDataStateInitial());
          } else {
            dev.log('dfas');
            emit(ImportDataStateFileChosen(file: result.files.first));
          }
        } else {
          emit(const ImportDataStateInitial());
        }
      },
    );

    on<ImportDataEventReinitialisePage>(
      (event, emit) {
        emit(const ImportDataStateLoading());
        emit(const ImportDataStateInitial());
      },
    );

    on<ImportDataEventFileNotChosenSubmit>(
      (event, emit) {
        emit(const ImportDataStateErrorFileNotChosenError());
        emit(const ImportDataStateInitial());
      },
    );

    on<ImportDataEventSubmit>(
      (event, emit) async {
        emit(const ImportDataStateLoading());
        final file = event.file;
        final date = event.date;
        if (date.isEmpty) {
          emit(const ImportDataStateErrorDateNotChosenError());
          emit(ImportDataStateFileChosen(file: event.file));
        } else {
          try {
            await provider.initialisePrices();
            await provider.importData(
                platformFile: file, importDate: date);
            emit(const ImportDataStateDataImported());
          } on Exception catch (e) {
            dev.log(e.toString());
            emit(const ImportDataStateError());
            emit(ImportDataStateFileChosen(file: event.file));
          }
        }
      },
    );
  }
}
