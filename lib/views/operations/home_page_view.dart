import 'package:electricity_plus/enums/menu_action.dart';
import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/dialogs/logout_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                default:
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: MenuAction.logout,
                  child: Text("Logout"),
                )
              ];
            },
          )
        ],
        title: const Text("Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<OperationBloc>()
                        .add(const OperationEventCustomerReceiptSearch(
                          isSearching: false,
                          userInput: '',
                        ));
                  },
                  child: const Text("Customer Receipt history"),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<OperationBloc>().add(
                        const OperationEventFlagCustomerSearch(
                            userInput: '', isSearching: false));
                  },
                  child: const Text("Flagged Customers"),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<OperationBloc>()
                        .add(const OperationEventElectricLogSearch(
                          isSearching: false,
                          userInput: '',
                        ));
                  },
                  child: const Text("Customer ELectric Log"),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<OperationBloc>()
                        .add(const OperationEventSetPrice(
                          price: '',
                          serviceCharge: '',
                          tokenInput: '',
                          isSettingPrice: false,
                          horsePowerPerUnitCost: '',
                          roadLightPrice: '',
                        ));
                  },
                  child: const Text("Set Price"),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<OperationBloc>().add(
                        const OperationEventAddCustomer());
                  },
                  child: const Text("Add Customer"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
