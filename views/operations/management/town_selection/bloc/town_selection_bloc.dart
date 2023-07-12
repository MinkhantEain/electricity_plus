import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:electricity_plus/services/others/town.dart';
import 'package:equatable/equatable.dart';

part 'town_selection_event.dart';
part 'town_selection_state.dart';

class TownSelectionBloc extends Bloc<TownSelectionEvent, TownSelectionState> {
  TownSelectionBloc(FirebaseCloudStorage provider, Iterable<Town> towns)
      : super(TownSelectionInitial(towns: towns)) {
    on<TownSelectionAdd>((event, emit) async {
      emit(TownSelectionLoading(
          loadingMessage: 'Please wait a while...', towns: super.state.towns));
      try {
        await provider.addTown(event.townName);
        final newTownList = await provider.getAllTown();
        await provider.setTownCount(newTownList.length);
        await AppDocumentData.storeTownList(newTownList);
        emit(TownSelectionLoaded(towns: newTownList));
        emit(TownSelectionStateTownAdded(
            townName: event.townName, towns: newTownList));
        emit(TownSelectionInitial(towns: newTownList));
      } on InvalidTownNameException {
        emit(TownSelectionLoaded(towns: super.state.towns));
        emit(TownSelectionEmptyTownNameInput(towns: super.state.towns));
        emit(TownSelectionInitial(towns: super.state.towns));
      }
    });

    on<TownSelectionDeleteSelect>(
      (event, emit) {
        emit(TownSelectionLoading(towns: super.state.towns, loadingMessage: 'Loading...'));
        emit(TownSelectionStateDeleteSelected(towns: super.state.towns, townName: event.townName));
      },
    );

    on<TownSelectionDelete>((event, emit) async {
      emit(TownSelectionLoading(
          loadingMessage: 'Please wait a while...', towns: super.state.towns));
      //get the current town name
      final currentTown = await AppDocumentData.getTownName();
      //if the current town name is equal to the town to be deleted, make the chosen town any of the left over town
      if (currentTown == event.townName) {
        final currentTownList = await AppDocumentData.getTownList();
        final newReplacementTown = currentTownList.where((element) => element.townName != currentTown).first;
        await AppDocumentData.storeTownName(newReplacementTown.townName);
      }
      await provider.deleteTown(event.townName);
      final newTownList = await provider.getAllTown();
      await provider.setTownCount(newTownList.length);
      await AppDocumentData.storeTownList(newTownList);
      emit(TownSelectionLoaded(towns: newTownList));
      emit(TownSelectionStateDeleted(
          townName: event.townName, towns: newTownList));
      emit(TownSelectionInitial(towns: newTownList));
    });

    on<TownSelectionSelected>((event, emit) async {
      emit(TownSelectionLoading(
          loadingMessage: 'Please wait a while...', towns: super.state.towns));
      await AppDocumentData.storeTownName(event.townName);
      emit(NewTownSelected(
          newTownName: event.townName, towns: super.state.towns));
      emit(TownSelectionInitial(towns: super.state.towns));
    });
  }
}
