import 'package:electricity_plus/enums/menu_action.dart';
import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/dialogs/home_page_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/logout_dialog.dart';
import 'package:electricity_plus/views/operations/customer_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ElectricLogSearchView extends StatefulWidget {
  const ElectricLogSearchView({super.key});

  @override
  State<ElectricLogSearchView> createState() => _ElectricLogSearchViewState();
}

class _ElectricLogSearchViewState extends State<ElectricLogSearchView> {
  late final TextEditingController _userInputTextController;

  @override
  void initState() {
    _userInputTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _userInputTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperationBloc, OperationState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        state as OperationStateElectricLogSearch;
        Iterable<CloudCustomer> customers = state.customerIterable;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Electric Log Search"),
            leading: BackButton(
              onPressed: () {
                context
                    .read<OperationBloc>()
                    .add(const OperationEventDefault());
              },
            ),
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
          body: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'BookID/MeterID',
                ),
                controller: _userInputTextController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<OperationBloc>().add(
                            const OperationEventElectricLogSearch(
                                isSearching: false, userInput: ''),
                          );
                      _userInputTextController.clear();
                    },
                    child: const Text("Reset"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<OperationBloc>().add(
                            OperationEventElectricLogSearch(
                                isSearching: true,
                                userInput: _userInputTextController.text),
                          );
                    },
                    child: const Text("Search"),
                  ),
                ],
              ),
              Expanded(
                child: CustomerListView(
                  customers: customers,
                  onTap: (customer) {
                    context
                        .read<OperationBloc>()
                        .add(OperationEventCreateNewElectricLog(newReading: '',
                          customer: customer,
                        ));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
