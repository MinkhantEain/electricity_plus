import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:electricity_plus/views/operations/flagged/bloc/flagged_bloc.dart';
import 'package:electricity_plus/views/operations/flagged/flag_list_view.dart';
import 'package:electricity_plus/views/operations/flagged/resolve_red_flag/bloc/resolve_red_flag_bloc.dart';
import 'package:electricity_plus/views/operations/flagged/resolve_red_flag/resolve_red_flag_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FlaggedView extends StatelessWidget {
  const FlaggedView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FlaggedBloc, FlaggedState>(
      listener: (context, state) {
        if (state is FlaggedStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is FlaggedInitial) {
          return Scaffold(
            appBar: AppBar(
              title: const Row(
                children: [
                  Text('Flagged'),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(Icons.flag_outlined),
                ],
              ),
              leading: BackButton(
                onPressed: () {
                  context
                      .read<OperationBloc>()
                      .add(const OperationEventDefault());
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  HomePageButton(
                    icon: const Icon(Icons.flag, color: Colors.red),
                    text: 'Error Meter',
                    onPressed: () {
                      //TODO: go to a view with all the flagged customer.
                      context.read<FlaggedBloc>().add(const FlaggedEventRed());
                    },
                  ),
                  HomePageButton(
                    icon: const Icon(
                      Icons.flag_sharp,
                      color: Colors.black,
                    ),
                    text: 'Unpaid Customer',
                    onPressed: () {
                      //TODO: got to a view with all the unapid customer.
                    },
                  )
                ],
              ),
            ),
          );
        } else if (state is FlaggedStatePageSelected) {
          return const FlagListView();
        } else if (state is FlaggedStateRedSelected) {
          return BlocProvider(
            create: (context) => ResolveRedFlagBloc(FirebaseCloudStorage(),
            customer: state.customer, flag: state.flag, image: state.image),
            child: const ResolveRedFlagView(),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
