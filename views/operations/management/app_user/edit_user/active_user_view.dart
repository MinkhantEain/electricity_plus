import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/views/operations/management/app_user/bloc/app_user_bloc.dart';
import 'package:electricity_plus/views/operations/management/app_user/edit_user/bloc/edit_user_bloc.dart';
import 'package:electricity_plus/views/operations/management/app_user/edit_user/edit_user_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActiveUserView extends StatelessWidget {
  const ActiveUserView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditUserBloc, EditUserState>(
      listener: (context, state) async {
        if (state is EditUserStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is EditUserStateUserToBeSuspended) {
            await showSuspendUserConfirmationDialog(
              context,
              state.toBeSuspendUser,
              state.currentActiveStaff,
            );
          }
        }
      },
      builder: (context, state) {
        if (state is EditUserStateActiveUserView) {
          var staffList = state.currentActiveStaff.toList();
          staffList.sort(
            (a, b) => a.compareTo(b),
          );
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  context.read<AppUserBloc>().add(const AppUserEventAppUser());
                },
              ),
              title: const Text('Active User'),
            ),
            body: ListView.builder(
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(staffList[index].name),
                      Text(staffList[index].userType),
                    ],
                  ),
                  onTap: () {
                    context
                        .read<EditUserBloc>()
                        .add(EditUserEventActiveUserSelect(
                          selectedUser: staffList[index],
                          currentActiveStaff: staffList.map((e) => e),
                        ));
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
