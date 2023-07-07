import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc(FirebaseCloudStorage provider) : super(const AdminInitial()) {
    on<AdminEventCheckAuthorisation>((event, emit) async {
      final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      if (await provider.isAdminPersonnel(currentUserUid)) {
        emit(const AdminStateAuthorisedUser());
      } else {
        emit(const AdminStateUnauthorisedUser());
      }
    });
  }
}
