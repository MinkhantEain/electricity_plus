import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'add_new_user_event.dart';
part 'add_new_user_state.dart';

class AddNewUserBloc extends Bloc<AddNewUserEvent, AddNewUserState> {
  AddNewUserBloc() : super(AddNewUserInitial()) {
    on<AddNewUserEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
