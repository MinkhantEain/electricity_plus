import 'dart:developer';

import 'package:electricity_plus/enums/menu_action.dart';
import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/helper/password_enquiry/password_enquiry_overlay.dart';
import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:electricity_plus/utilities/dialogs/admin_page_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/home_page_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/logout_dialog.dart';
import 'package:electricity_plus/views/operations/management/bloc/admin_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  Future<String> scanQRcode() async {
    String barCodeScanResult;
    try {
      barCodeScanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );
    } on PlatformException {
      barCodeScanResult = '';
    }

    if (!mounted) {
      return '';
    }

    return barCodeScanResult;
  }

  @override
  Widget build(BuildContext context) {
    // return BlocConsumer<AdminBloc, AdminState>(
    //   listener: (context, state) async {
        // if (state is AdminStateUnauthorisedUser) {
        //   LoadingScreen().hide();
        //   await showUnauthorisedUserDialog(context);
        // } else if (state is AdminStateAuthorisedUser) {
        //   LoadingScreen().hide();
        // } else {
        //   LoadingScreen().show(context: context, text: 'Loading...');
        // }
      // },
      // builder: (context, state) {
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
                        context.read<AuthBloc>().add(AuthEventLogOut(townList: await AppDocumentData.getTownList()));
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
                    icon: const Icon(Icons.person_add_alt_outlined),
                    text: "Add Customer",
                    onPressed: () {
                      context
                          .read<OperationBloc>()
                          .add(const OperationEventAddCustomer());
                    },
                  ),

                  HomePageButton(
                    icon: const Icon(Icons.person_outline_outlined),
                    text: "App User",
                    onPressed: () {
                      context.read<OperationBloc>().add(const OperationEventAppUser());
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
                  HomePageButton(
                    icon: const Icon(Icons.home_work_outlined),
                    text: "Town",
                    onPressed: () {
                      PasswordEnquiry().show(
                        context: context,
                        onTap: () {
                          context
                              .read<OperationBloc>()
                              .add(const OperationEventChooseTown());
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }}
//     );
//   }
// }
