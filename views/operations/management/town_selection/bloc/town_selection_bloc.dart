import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:electricity_plus/services/others/town.dart';
import 'package:electricity_plus/views/operations/management/town_selection/bloc/town_selection_exception.dart';
import 'package:equatable/equatable.dart';

part 'town_selection_event.dart';
part 'town_selection_state.dart';

class TownSelectionBloc extends Bloc<TownSelectionEvent, TownSelectionState> {
  TownSelectionBloc(FirebaseCloudStorage provider)
      : super(const TownSelectionInitial()) {
    on<TownSelectionInitialise>(
      (event, emit) async {
        emit(const TownSelectionLoading(loadingMessage: null));
        //get all towns from firestore
        final cloudTowns = await provider.getAllTown();
        //populate the result into the local data
        AppDocumentData.storeTownList(cloudTowns);
        emit(const TownSelectionLoaded());
        //emit initial state
        emit(TownSelectionInitialised(towns: cloudTowns));
      },
    );

    on<TownSelectionAdd>((event, emit) async {
      emit(
          const TownSelectionLoading(loadingMessage: 'Please wait a while...'));
      if (!(await provider.verifyPassword(event.password))) {
        emit(const TownSelectionError(
            message: 'Invalid Password',
            exception: InvalidPasswordException()));
        emit(TownSelectionInitialised(
            towns: await AppDocumentData.getTownList()));
      } else {
        try {
          await provider.addTown(event.townName);
          final newTownList = await provider.getAllTown();
          await AppDocumentData.storeTownList(newTownList);
          emit(const TownSelectionLoaded());
          emit(TownSelectionStateTownAdded(townName: event.townName));
          emit(TownSelectionInitialised(towns: newTownList));
        } on InvalidTownNameException {
          emit(const TownSelectionLoaded());
          emit(const TownSelectionEmptyTownNameInput());
          emit(TownSelectionInitialised(
            towns: await AppDocumentData.getTownList()));
        }
      }
    });

    on<TownSelectionDelete>((event, emit) async {
      emit(
          const TownSelectionLoading(loadingMessage: 'Please wait a while...'));
      if (!(await provider.verifyPassword(event.password))) {
        emit(const TownSelectionError(
            message: 'Invalid Password',
            exception: InvalidPasswordException()));
        emit(TownSelectionInitialised(
            towns: await AppDocumentData.getTownList()));
      } else {
        await provider.deleteTown(event.townName);
        final newTownList = await provider.getAllTown();
        await AppDocumentData.storeTownList(newTownList);
        emit(const TownSelectionLoaded());
        emit(TownSelectionStateDeleted(townName: event.townName));
        emit(TownSelectionInitialised(towns: newTownList));
      }
    });

    on<TownSelectionSelected>((event, emit) async {
      if (await provider.verifyPassword(event.password)) {
        emit(const TownSelectionLoading(
            loadingMessage: 'Please wait a while...'));
        await AppDocumentData.storeTownName(event.townName);
        emit(NewTownSelected(newTownName: event.townName));
        emit(TownSelectionInitialised(
            towns: await AppDocumentData.getTownList()));
      } else {
        emit(const TownSelectionError(
            message: 'Invalid Password',
            exception: InvalidPasswordException()));
        emit(TownSelectionInitialised(
            towns: await AppDocumentData.getTownList()));
      }
    });
  }
}
