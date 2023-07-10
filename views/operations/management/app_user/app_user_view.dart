import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:electricity_plus/views/operations/management/app_user/add_new_user/bloc/add_new_user_bloc.dart';
import 'package:electricity_plus/views/operations/management/app_user/bloc/app_user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_new_user/add_new_user_view.dart';

class AppUserView extends StatelessWidget {
  const AppUserView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUserBloc, AppUserState>(
      builder: (context, state) {
        if (state is AppUserInitial) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () async {
                  context
                      .read<OperationBloc>()
                      .add(const OperationEventAdminView());
                  await BlocProvider.of<AppUserBloc>(context).close();
                },
              ),
              title: const Text('App User'),
            ),
            body: SingleChildScrollView(
                child: Column(
              children: [
                HomePageButton(
                    icon: const Icon(Icons.person_add_alt_outlined),
                    text: 'Add new user',
                    onPressed: () {
                      context.read<AppUserBloc>().add(const AppUserEventAddNewUser());
                    }),
                HomePageButton(
                    icon: const Icon(Icons.chrome_reader_mode_outlined),
                    text: 'meter Read History',
                    onPressed: () {}),
                HomePageButton(
                    icon: const Icon(Icons.history_edu),
                    text: 'Payment Collections',
                    onPressed: () {}),
                HomePageButton(
                    icon: const Icon(Icons.assignment_late_outlined),
                    text: 'Suspend User',
                    onPressed: () {}),
                HomePageButton(
                    icon: const Icon(Icons.assignment_ind_outlined),
                    text: 'Activate User',
                    onPressed: () {}),
              ],
            )),
          );
        } else if (state is AppUserStateAddNewUser) {
          return BlocProvider(
            create: (context) => AddNewUserBloc(),
            child: const AddNewUserView(),
          );
        } else if (state is AppUserStateUserMeterReadHisotry) {
          return const Scaffold();
        } else if (state is AppUserStateUserPaymentCollectedHistory) {
          return const Scaffold();
        } else if (state is AppUserStateSuspendUser) {
          return const Scaffold();
        } else if (state is AppUserStateActivateUser) {
          return const Scaffold();
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
