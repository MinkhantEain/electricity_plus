import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/custom_button.dart';
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
    return BlocBuilder<OperationBloc, OperationState>(
      builder: (context, state) {
        state as OperationStateDefault;
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                    context
                        .read<OperationBloc>()
                        .add(const OperationEventChooseBluetooth());
                  },
                  icon: const Icon(Icons.print_outlined)),
              AppBarMenu(context),
            ],
            title: Text("Town: ${state.townName}"),
          ),
          body: GridView.count(
            padding: const EdgeInsets.all(10),
            crossAxisCount: 3,
            children: [
              HomePageButton(
                icon: Icons.receipt_long_outlined,
                text: "Bill",
                onPressed: () {
                  context
                      .read<OperationBloc>()
                      .add(const OperationEventCustomerReceiptSearch(
                        isSearching: false,
                        userInput: '',
                      ));
                },
              ),
              HomePageButton(
                icon: Icons.flag_outlined,
                text: "Flagged Customer",
                onPressed: () {
                  context.read<OperationBloc>().add(
                      const OperationEventFlagCustomerSearch(
                          userInput: '', isSearching: false));
                },
              ),
              HomePageButton(
                icon: Icons.assignment_turned_in_outlined,
                text: "Electric Log",
                onPressed: () {
                  context
                      .read<OperationBloc>()
                      .add(const OperationEventElectricLogSearch(
                        isSearching: false,
                        userInput: '',
                      ));
                },
              ),
              HomePageButton(
                icon: Icons.assignment_ind_outlined,
                text: "Admin",
                onPressed: () {
                  context
                      .read<OperationBloc>()
                      .add(const OperationEventAdminView());
                },
              ),
            ],
          ),
          // body: Padding(
          //   padding: const EdgeInsets.all(0.0),
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [

          //       HomePageButton(
          //         icon: Icons.receipt_long_outlined,
          //         text: "Bill",
          //         onPressed: () {
          //           context
          //               .read<OperationBloc>()
          //               .add(const OperationEventCustomerReceiptSearch(
          //                 isSearching: false,
          //                 userInput: '',
          //               ));
          //         },
          //       ),
          //       HomePageButton(
          //         icon: Icons.flag_outlined,
          //         text: "Flagged Customer",
          //         onPressed: () {
          //           context.read<OperationBloc>().add(
          //               const OperationEventFlagCustomerSearch(
          //                   userInput: '', isSearching: false));
          //         },
          //       ),
          //       HomePageButton(
          //         icon: Icons.assignment_turned_in_outlined,
          //         text: "Electric Log",
          //         onPressed: () {
          //           context
          //               .read<OperationBloc>()
          //               .add(const OperationEventElectricLogSearch(
          //                 isSearching: false,
          //                 userInput: '',
          //               ));
          //         },
          //       ),
          //       HomePageButton(
          //         icon: Icons.assignment_ind_outlined,
          //         text: "Admin",
          //         onPressed: () {
          //           context
          //               .read<OperationBloc>()
          //               .add(const OperationEventAdminView());
          //         },
          //       ),
          //     ],
          //   ),
          // ),
        );
      },
    );
  }
}
