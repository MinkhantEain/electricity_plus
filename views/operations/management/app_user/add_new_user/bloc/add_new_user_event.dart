part of 'add_new_user_bloc.dart';

abstract class AddNewUserEvent extends Equatable {
  const AddNewUserEvent();

  @override
  List<Object> get props => [];
}

class AddNewUserEventSubmit extends AddNewUserEvent {
  final String name;
  final String email;
  final String password;
  final String passwordReEntry;
  final String userType;
  const AddNewUserEventSubmit(
    {
      required this.email,
      required this.name,
      required this.password,
      required this.passwordReEntry,
      required this.userType,
    }
  );
}