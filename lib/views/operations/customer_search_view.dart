import 'package:electricity_plus/enums/menu_action.dart';
import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/cloud/cloud_customer.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/dialogs/home_page_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electricity_plus/views/operations/customer_list_view.dart';

class CustomerSearchView extends StatefulWidget {
  final Iterable<CloudCustomer>? cloudCustomers;
  const CustomerSearchView({super.key, this.cloudCustomers});

  @override
  State<CustomerSearchView> createState() => _CustomerSearchViewState();
}

class _CustomerSearchViewState extends State<CustomerSearchView> {
  late final FirebaseCloudStorage _customerCloudService;
  late final TextEditingController _textController;
  // String get bookID =>

  @override
  void initState() {
    _customerCloudService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Payment/Receipt"),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
                  break;
                case MenuAction.home:
                  final shouldGoHome = await showHomePageDialog(context);
                  if (shouldGoHome) {
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
          const Text("Book ID/Meter Number:"),
          TextField(
            controller: _textController,
          ),
          ElevatedButton(
            onPressed: () {
              String userInput = _textController.text;
              context.read<OperationBloc>().add(OperationEventCustomerSearch(
                  userInput: userInput, isSearching: true));
            },
            child: const Text("Enter"),
          ),StreamBuilder(
              stream: _customerCloudService.allCustomer(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    if (snapshot.hasData) {
                      final allCustomers =
                          snapshot.data as Iterable<CloudCustomer>;
                      return Expanded(
                        flex: 5,
                        child: CustomerListView(
                          onTap: (customer) {
                            context.read<OperationBloc>().add(
                                OperationEventReceiptGeneration(
                                    customer: customer));
                          },
                          customers: allCustomers,
                        ),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  default:
                    return const CircularProgressIndicator();
                }
              },
            )
          
        ],
      ),
    );
  }
}
