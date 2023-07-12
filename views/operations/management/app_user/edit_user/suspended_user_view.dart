import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/views/operations/management/app_user/bloc/app_user_bloc.dart';
import 'package:electricity_plus/views/operations/management/app_user/edit_user/bloc/edit_user_bloc.dart';
import 'package:electricity_plus/views/operations/management/app_user/edit_user/edit_user_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SuspendedUserView extends StatelessWidget {
  const SuspendedUserView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditUserBloc, EditUserState>(
      listener: (context, state) async {
        if (state is EditUserStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is EditUserStateStaffToBeActivated) {
            await showUserTypeOptionDialog(
                context, state.selectedUser, state.currentSuspendedUsers);
          } else if (state is EditUserStateSuspendedUserActivated) {
            await showUserActivatedDialog(
              context,
              state.activatedUser,
            );
          } else if (state is EditUserStateStaffToBeDeleted) {
            await showDeleteUserConfirmationDialog(
                context, state.toBeDeletedStaff, state.currentSuspendedUsers);
          } else if (state is EditUserStateSuspendedUserDeleted) {
            await showUserDeletedDialog(context, state.deletedUser);
          }
        }
      },
      builder: (context, state) {
        if (state is EditUserStateSuspendedUserView) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Suspended Users'),
              leading: BackButton(
                onPressed: () {
                  context.read<AppUserBloc>().add(const AppUserEventAppUser());
                },
              ),
            ),
            body: ListView.builder(
              itemCount: state.currentSuspendedUsers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Name: ${state.currentSuspendedUsers.elementAt(index).name}'),
                          Text(
                              'Email: ${state.currentSuspendedUsers.elementAt(index).email}')
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            context
                                .read<EditUserBloc>()
                                .add(EditUserEventDeleteSuspendedUserSelect(
                                  currentSuspendedStaffs:
                                      state.currentSuspendedUsers,
                                  toBeDeletedStaff: state.currentSuspendedUsers
                                      .elementAt(index),
                                ));
                          },
                          icon: const Icon(Icons.delete_outlined))
                    ],
                  ),
                  onTap: () {
                    context.read<EditUserBloc>().add(
                        EditUserEventSuspendedUserSelect(
                            selectedSuspendedStaff:
                                state.currentSuspendedUsers.elementAt(index),
                            currentSuspendedStaffs:
                                state.currentSuspendedUsers));
                  },
                );
              },
            ),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
