part of 'edit_user_bloc.dart';

abstract class EditUserState extends Equatable {
  const EditUserState();

  @override
  List<Object> get props => [];
}

class EditUserInitial extends EditUserState {
  const EditUserInitial();
}

//---------------------------------------------
//for active view
class EditUserStateLoading extends EditUserState {
  const EditUserStateLoading();
}

class EditUserStateActiveUserView extends EditUserState {
  final Iterable<Staff> currentActiveStaff;
  const EditUserStateActiveUserView({required this.currentActiveStaff});
  @override
  List<Object> get props => [super.props, currentActiveStaff];
}

class EditUserStateUserToBeSuspended extends EditUserState {
  final Staff toBeSuspendUser;
  final Iterable<Staff> currentActiveStaff;
  const EditUserStateUserToBeSuspended(
      {required this.toBeSuspendUser, required this.currentActiveStaff});

  @override
  List<Object> get props => [super.props, toBeSuspendUser, currentActiveStaff];
}

//-----------------------------------------------
//for suspended view
class EditUserStateSuspendedUserView extends EditUserState {
  final Iterable<Staff> currentSuspendedUsers;
  const EditUserStateSuspendedUserView({required this.currentSuspendedUsers});

  @override
  List<Object> get props => [super.props, currentSuspendedUsers];
}

class EditUserStateStaffToBeActivated extends EditUserState {
  final Iterable<Staff> currentSuspendedUsers;
  final Staff selectedUser;
  const EditUserStateStaffToBeActivated({
    required this.currentSuspendedUsers,
    required this.selectedUser,
  });

  @override
  List<Object> get props => [super.props, selectedUser, currentSuspendedUsers];
}

class EditUserStateSuspendedUserActivated extends EditUserState {
  final Staff activatedUser;
  const EditUserStateSuspendedUserActivated({
    required this.activatedUser,
  });
  @override
  List<Object> get props => [super.props, activatedUser];
}

class EditUserStateSuspendedUserDeleted extends EditUserState {
  final Staff deletedUser;
  const EditUserStateSuspendedUserDeleted({
    required this.deletedUser,
  });
  @override
  List<Object> get props => [super.props, deletedUser];
}


class EditUserStateStaffToBeDeleted extends EditUserState {
  final Iterable<Staff> currentSuspendedUsers;
  final Staff toBeDeletedStaff;
  const EditUserStateStaffToBeDeleted({
    required this.currentSuspendedUsers,
    required this.toBeDeletedStaff,
  });

  @override
  List<Object> get props => [super.props, toBeDeletedStaff, currentSuspendedUsers];
}
