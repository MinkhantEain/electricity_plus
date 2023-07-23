

import 'package:electricity_plus/enums/menu_action.dart';
import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/helper/password_enquiry/password_enquiry_overlay.dart';
import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:electricity_plus/utilities/dialogs/home_page_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/logout_dialog.dart';
import 'package:electricity_plus/views/operations/customer_search/bloc/customer_search_bloc.dart';
import 'package:electricity_plus/views/operations/customer_search/customer_search_view.dart';
import 'package:electricity_plus/views/operations/management/app_user/app_user_view.dart';
import 'package:electricity_plus/views/operations/management/app_user/bloc/app_user_bloc.dart';
import 'package:electricity_plus/views/operations/management/bloc/admin_bloc.dart';
import 'package:electricity_plus/views/operations/management/monthly_total_view.dart';
import 'package:electricity_plus/views/operations/management/town_selection/bloc/town_selection_bloc.dart';
import 'package:electricity_plus/views/operations/management/town_selection/town_selection_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is AdminStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AdminInitial) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  context
                      .read<OperationBloc>()
                      .add(const OperationEventDefault());
                },
              ),
              title: const Text('Management'),
              actions: [
                PopupMenuButton<MenuAction>(
                  onSelected: (value) async {
                    switch (value) {
                      case MenuAction.logout:
                        final shouldLogout = await showLogOutDialog(context);
                        if (shouldLogout) {
                          // ignore: use_build_context_synchronously
                          context.read<AuthBloc>().add(AuthEventLogOut(
                              townList: await AppDocumentData.getTownList()));
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomePageButton(
                      icon: const Icon(Icons.pending_actions_outlined),
                      text: "Monthly Total",
                      onPressed: () {
                        context.read<AdminBloc>().add(const AdminEventMonthlyTotal());
                      },
                    ),
                    HomePageButton(
                      icon: const Icon(Icons.price_change_outlined),
                      text: 'Set Price',
                      onPressed: () {
                        PasswordEnquiry().show(
                          context: context,
                          onTap: () {
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
                        );
                      },
                    ),
                    HomePageButton(
                      icon: const Icon(Icons.change_circle_outlined),
                      text: "Exchange Meter",
                      onPressed: () {
                        context
                            .read<AdminBloc>()
                            .add(const AdminEventExchangeMeter());
                      },
                    ),
                    HomePageButton(
                      icon: const Icon(Icons.person_add_alt_outlined),
                      text: "Add Customer",
                      onPressed: () {
                        context
                            .read<OperationBloc>()
                            .add(const OperationEventAddCustomer());
                      },
                    ),
                    HomePageButton(
                      icon: const Icon(Icons.mode_edit_outline_outlined),
                      text: "Edit Customer",
                      onPressed: () {
                        context.read<AdminBloc>().add(const AdminEventEditCustomer());
                      },
                    ),
                    HomePageButton(
                      icon: const Icon(Icons.person_outline_outlined),
                      text: "App User",
                      onPressed: () {
                        context
                            .read<AdminBloc>()
                            .add(const AdminEventAppUser());
                      },
                    ),
                    HomePageButton(
                      icon: const Icon(Icons.download_outlined),
                      text: "Produce Excel",
                      onPressed: () {
                        PasswordEnquiry().show(
                            context: context,
                            onTap: () {
                              context
                                  .read<OperationBloc>()
                                  .add(const OperationEventProduceExcel());
                            });
                      },
                    ),
                    HomePageButton(
                      icon: const Icon(Icons.import_export_sharp),
                      text: "Initialise Data",
                      onPressed: () {
                        context
                            .read<OperationBloc>()
                            .add(const OperationEventInitialiseData());
                      },
                    ),
                    
                    Visibility(
                      visible: state.userType == directorType,
                      child: HomePageButton(
                        icon: const Icon(Icons.home_work_outlined),
                        text: "Town",
                        onPressed: () {
                          PasswordEnquiry().show(
                            context: context,
                            onTap: () {
                              context
                                  .read<AdminBloc>()
                                  .add(const AdminEventChooseTown());
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is AdminStateChooseTown) {
          return BlocProvider(
            create: (context) =>
                TownSelectionBloc(FirebaseCloudStorage(), state.towns),
            child: const TownSelectionView(),
          );
        } else if (state is AdminStateAppUser) {
          return BlocProvider(
            create: (context) => AppUserBloc(),
            child: const AppUserView(),
          );
        } else if (state is AdminStateExchangeMeter) {
          return BlocProvider(
            create: (context) => CustomerSearchBloc(FirebaseCloudStorage())
              ..add(const CustomerSearchExchangeMeterSearchInitialise()),
            child: const CustomerSearchView(),
          );
        } else if (state is AdminStateMonthlyTotal) {
          return const MonthlyTotalView();
        } else if (state is AdminStateEditCustomer) {
          return BlocProvider(
            create: (context) => CustomerSearchBloc(FirebaseCloudStorage())
              ..add(const CustomerSearchEditCustomerSearchInitialise()),
            child: const CustomerSearchView(),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
//     );
//   }
// }
