import 'package:electricity_plus/enums/menu_action.dart';
import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:electricity_plus/utilities/dialogs/home_page_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.read<OperationBloc>().add(const OperationEventDefault());
          },
        ),
        title: const Text('Admin'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    // ignore: use_build_context_synchronously
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
                  break;
                case MenuAction.home:
                  final shouldGoHome = await showHomePageDialog(context);
                  if (shouldGoHome) {
                    // ignore: use_build_context_synchronously
                    context
                        .read<OperationBloc>()
                        .add(const OperationEventDefault());
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: MenuAction.home,
                  child: Text("Home"),
                ),
                PopupMenuItem(
                  value: MenuAction.logout,
                  child: Text("Logout"),
                ),
              ];
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HomePageButton(
              icon: Icons.price_change_outlined,
              text: 'Set Price',
              onPressed: () {
                context.read<OperationBloc>().add(const OperationEventSetPrice(
                      price: '',
                      serviceCharge: '',
                      tokenInput: '',
                      isSettingPrice: false,
                      horsePowerPerUnitCost: '',
                      roadLightPrice: '',
                    ));
              },
            ),
            HomePageButton(
              icon: Icons.person_add_alt_outlined,
              text: "Add Customer",
              onPressed: () {
                context
                    .read<OperationBloc>()
                    .add(const OperationEventAddCustomer());
              },
            ),
            HomePageButton(
              icon: Icons.download_outlined,
              text: "Produce Excel",
              onPressed: () {
                context.read<OperationBloc>().add(
                  const OperationEventProduceExcel()
                );
              },
            ),
            HomePageButton(
              icon: Icons.import_export_sharp,
              text: "Initialise Data",
              onPressed: () {
                context.read<OperationBloc>().add(
                    const OperationEventInitialiseData(
                        result: null, submit: false));
              },
            ),
          ],
        ),
      ),
    );
  }
}
