import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/models/users.dart';
import 'package:equatable/equatable.dart';

part 'edit_user_event.dart';
part 'edit_user_state.dart';

class EditUserBloc extends Bloc<EditUserEvent, EditUserState> {
  EditUserBloc(FirebaseCloudStorage provider) : super(const EditUserInitial()) {
    on<EditUserEventActiveUserView>(
      (event, emit) async {
        emit(const EditUserStateLoading());
        late final Iterable<Staff> currentActiveStaff;
        if (event.currentActiveStaff.isEmpty) {
          currentActiveStaff = await provider.getAllActiveStaff();
        } else {
          currentActiveStaff = event.currentActiveStaff;
        }
        emit(EditUserStateActiveUserView(
            currentActiveStaff: currentActiveStaff));
      },
    );

    on<EditUserEventSuspendUserView>(
      (event, emit) async {
        emit(const EditUserStateLoading());
        late final Iterable<Staff> currentSuspendedStaffs;
        if (event.currentSuspendedStaffs.isEmpty) {
          currentSuspendedStaffs = await provider.getAllSuspendedStaff();
        } else {
          currentSuspendedStaffs = event.currentSuspendedStaffs;
        }
        emit(EditUserStateSuspendedUserView(
            currentSuspendedUsers: currentSuspendedStaffs));
      },
    );

    on<EditUserEventActiveUserSelect>(
      (event, emit) {
        emit(const EditUserStateLoading());
        emit(EditUserStateUserToBeSuspended(
          toBeSuspendUser: event.selectedUser,
          currentActiveStaff: event.currentActiveStaff,
        ));
      },
    );

    on<EditUserEventSuspendedUserSelect>(
      (event, emit) {
        emit(const EditUserStateLoading());
        emit(EditUserStateStaffToBeActivated(
            currentSuspendedUsers: event.currentSuspendedStaffs,
            selectedUser: event.selectedSuspendedStaff));
      },
    );

    on<EditUserEventDeleteSuspendedUserSelect>(
      (event, emit) {
        emit(const EditUserStateLoading());
        emit(EditUserStateStaffToBeDeleted(
            currentSuspendedUsers: event.currentSuspendedStaffs,
            toBeDeletedStaff: event.toBeDeletedStaff));
        emit(EditUserStateSuspendedUserView(
            currentSuspendedUsers: event.currentSuspendedStaffs));
      },
    );

    on<EditUserEventSuspendUser>(
      (event, emit) async {
        emit(const EditUserStateLoading());
        await provider.suspendStaff(event.toBeSuspendUser);
        var staffList = event.currentActiveStaff.toList();
        staffList.remove(event.toBeSuspendUser);
        emit(EditUserStateActiveUserView(currentActiveStaff: staffList));
      },
    );

    on<EditUserEventActivateSuspendedUser>(
      (event, emit) async {
        emit(const EditUserStateLoading());
        await provider.activateUser(event.toBeActivatedStaff, event.userType);
        var staffList = event.currentSuspendedStaffs.toList();
        staffList = staffList.where((staff) => staff.uid != event.toBeActivatedStaff.uid).toList();
        emit(EditUserStateSuspendedUserActivated(
            activatedUser: event.toBeActivatedStaff));
        emit(EditUserStateSuspendedUserView(currentSuspendedUsers: staffList));
      },
    );

    on<EditUserEventDeleteSuspendedUser>(
      (event, emit) async {
        emit(const EditUserStateLoading());
        await provider.deleteStaff(staff: event.toBeDeletedStaff);
        emit(EditUserStateSuspendedUserDeleted(
            deletedUser: event.toBeDeletedStaff));
        var staffList = event.currentSuspendedStaffs.toList();
        staffList.remove(event.toBeDeletedStaff);
        emit(EditUserStateSuspendedUserView(currentSuspendedUsers: staffList));
      },
    );
  }
}
