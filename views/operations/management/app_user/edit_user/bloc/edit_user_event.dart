part of 'edit_user_bloc.dart';

abstract class EditUserEvent extends Equatable {
  const EditUserEvent();

  @override
  List<Object> get props => [];
}

class EditUserEventActiveUserView extends EditUserEvent {
  final Iterable<Staff> currentActiveStaff;
  const EditUserEventActiveUserView({required this.currentActiveStaff});
  @override
  List<Object> get props => [super.props, currentActiveStaff];
}

class EditUserEventActiveUserSelect extends EditUserEvent {
  final Staff selectedUser;
  final Iterable<Staff> currentActiveStaff;
  const EditUserEventActiveUserSelect({
    required this.selectedUser,
    required this.currentActiveStaff,
  });

  @override
  List<Object> get props => [
        super.props,
        selectedUser,
        currentActiveStaff,
      ];
}

class EditUserEventSuspendUser extends EditUserEvent {
  final Staff toBeSuspendUser;
  final Iterable<Staff> currentActiveStaff;
  const EditUserEventSuspendUser({
    required this.toBeSuspendUser,
    required this.currentActiveStaff,
  });

  @override
  List<Object> get props => [super.props, toBeSuspendUser, currentActiveStaff];
}

//-----------------------------------------------------
//suspended user

class EditUserEventSuspendUserView extends EditUserEvent {
  final Iterable<Staff> currentSuspendedStaffs;
  const EditUserEventSuspendUserView({required this.currentSuspendedStaffs});

  @override
  List<Object> get props => [super.props, currentSuspendedStaffs];
}

class EditUserEventSuspendedUserSelect extends EditUserEvent {
  final Iterable<Staff> currentSuspendedStaffs;
  final Staff selectedSuspendedStaff;
  const EditUserEventSuspendedUserSelect({
    required this.currentSuspendedStaffs,
    required this.selectedSuspendedStaff,
  });

  @override
  List<Object> get props =>
      [super.props, currentSuspendedStaffs, selectedSuspendedStaff];
}

class EditUserEventActivateSuspendedUser extends EditUserEvent {
  final Iterable<Staff> currentSuspendedStaffs;
  final String userType;
  final Staff toBeActivatedStaff;
  const EditUserEventActivateSuspendedUser(
      {required this.currentSuspendedStaffs,
      required this.toBeActivatedStaff,
      required this.userType});

  @override
  List<Object> get props => [
        super.props,
        currentSuspendedStaffs,
        toBeActivatedStaff,
        userType,
      ];
}

class EditUserEventDeleteSuspendedUser extends EditUserEvent {
  final Iterable<Staff> currentSuspendedStaffs;
  final Staff toBeDeletedStaff;
  const EditUserEventDeleteSuspendedUser({
    required this.currentSuspendedStaffs,
    required this.toBeDeletedStaff,
  });

  @override
  List<Object> get props => [super.props, currentSuspendedStaffs, toBeDeletedStaff];
}


class EditUserEventDeleteSuspendedUserSelect extends EditUserEvent {
  final Iterable<Staff> currentSuspendedStaffs;
  final Staff toBeDeletedStaff;
  const EditUserEventDeleteSuspendedUserSelect({
    required this.currentSuspendedStaffs,
    required this.toBeDeletedStaff,
  });

  @override
  List<Object> get props => [super.props, currentSuspendedStaffs, toBeDeletedStaff];
}