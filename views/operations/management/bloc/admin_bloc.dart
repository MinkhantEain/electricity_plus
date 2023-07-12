import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:electricity_plus/services/others/town.dart';
import 'package:equatable/equatable.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc(FirebaseCloudStorage provider) : super(const AdminInitial()) {
    on<AdminEventAdminView>((event, emit) => emit(const AdminInitial()),);
    on<AdminEventChooseTown>(
      (event, emit) async {
        emit(const AdminLoading());
        late final Iterable<Town> cloudTowns;
        final localCount = await AppDocumentData.townCount();
        final dbCount = await provider.getTownCount();
        if (localCount == dbCount) {
          cloudTowns = await AppDocumentData.getTownList();
        } else {
          cloudTowns = await provider.getAllTown();
          await AppDocumentData.storeTownList(cloudTowns);
        }
        emit(AdminStateChooseTown(towns: cloudTowns));
      },
    );
  }
}
