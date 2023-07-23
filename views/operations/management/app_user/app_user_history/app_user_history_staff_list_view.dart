import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/models/users.dart';
import 'package:electricity_plus/views/operations/management/app_user/app_user_history/app_user_history_staff_view.dart';
import 'package:electricity_plus/views/operations/management/app_user/app_user_history/bloc/app_user_history_bloc.dart';
import 'package:electricity_plus/views/operations/management/app_user/bloc/app_user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppUserHistoryStaffListView extends StatelessWidget {
  const AppUserHistoryStaffListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppUserHistoryBloc, AppUserHistoryState>(
      listener: (context, state) {
        if (state is AppUserHistoryStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AppUserHistoryInitial) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('App User History'),
              leading: BackButton(
                onPressed: () => context
                    .read<AppUserBloc>()
                    .add(const AppUserEventAppUser()),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      context
                          .read<AppUserHistoryBloc>()
                          .add(AppUserHistoryEventSelect(
                            staff: const Staff(
                              uid: 'uid',
                              email: 'email',
                              name: 'Daily Total',
                              password: 'password',
                              userType: meterReaderType,
                              isStaff: true,
                            ),
                            staffList: state.staffList,
                          ));
                    },
                    child: const Text('Total')),
              ],
            ),
            body: ListView.builder(
              itemCount: state.staffList.length,
              itemBuilder: (context, index) {
                final staff = state.staffList.elementAt(index);
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(staff.name),
                      Text(staff.userType),
                    ],
                  ),
                  onTap: () {
                    context
                        .read<AppUserHistoryBloc>()
                        .add(AppUserHistoryEventSelect(
                          staff: staff,
                          staffList: state.staffList,
                        ));
                  },
                );
              },
            ),
          );
        } else if (state is AppUserHistoryStateSelected) {
          return const AppUserHistoryStaffView();
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
