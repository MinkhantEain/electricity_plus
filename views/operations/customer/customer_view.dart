// import 'package:electricity_plus/helper/loading/loading_screen.dart';
// import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
// import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
// import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
// import 'package:electricity_plus/utilities/custom_button.dart';
// import 'package:electricity_plus/views/operations/bill_history/bill_history_view.dart';
// import 'package:electricity_plus/views/operations/bill_history/bloc/bill_history_bloc.dart';
// import 'package:electricity_plus/views/operations/customer/bloc/customer_bloc.dart';
// import 'package:electricity_plus/views/operations/read_meter/bloc/read_meter_bloc.dart';
// import 'package:electricity_plus/views/operations/read_meter/read_meter_first_page.dart';
// import 'package:electricity_plus/views/operations/resolve_red_flag/bloc/resolve_red_flag_bloc.dart';
// import 'package:electricity_plus/views/operations/resolve_red_flag/resolve_issue_view.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class CustomerView extends StatelessWidget {
//   const CustomerView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<CustomerBloc, CustomerState>(
//       listener: (context, state) {
//         if (state is CustomerStateLoading) {
//           LoadingScreen().show(context: context, text: 'Loading...');
//         } else {
//           LoadingScreen().hide();
//         }
//       },
//       builder: (context, state) {
//         if (state is CustomerStateInitial) {
//           return Scaffold(
//             appBar: AppBar(
//               leading: BackButton(
//                 onPressed: () {
//                   context
//                       .read<OperationBloc>()
//                       .add(const OperationEventDefault());
//                 },
//               ),
//             ),
//             body: SingleChildScrollView(
//               child: Column(children: [
//                 Visibility(
//                   visible: !state.customer.flag,
//                   child: HomePageButton(
//                       icon: Icons.assignment_turned_in_outlined,
//                       text: 'Electric Log',
//                       onPressed: () {
//                         context
//                             .read<CustomerBloc>()
//                             .add(const CustomerEventELectricLog());
//                       }),
//                 ),
//                 HomePageButton(
//                     icon: Icons.history_edu_rounded,
//                     text: 'Receipt History',
//                     onPressed: () {
//                       context
//                           .read<CustomerBloc>()
//                           .add(const CustomerEventLogHistory());
//                     }),
//                 Visibility(
//                   visible: state.customer.flag,
//                   child: HomePageButton(
//                       icon: Icons.report_problem_outlined,
//                       text: 'Resolve Issue',
//                       onPressed: () {
//                         context
//                             .read<CustomerBloc>()
//                             .add(const CustomerEventResolveIssue());
//                       }),
//                 ),
//               ]),
//             ),
//           );
//         } else if (state is CustomerStateElectricLog) {
//           return BlocProvider(
//             create: (context) => ReadMeterBloc(FirebaseCloudStorage(),
//                 state.customer, state.previousUnit.toString()),
//             child: const ReadMeterFirstPage(),
//           );
//         } else if (state is CustomerStateLogHistory) {
//           return BlocProvider(
//             create: (context) => BillHistoryBloc(
//                 historyList: state.historyList, customer: state.customer),
//             child: const BillHistoryView(),
//           );
//         } else if (state is CustomerStateResolveIssue) {
//           return BlocProvider(
//             create: (context) => ResolveRedFlagBloc(FirebaseCloudStorage() ,customer: state.customer, flag: state.flag,image: state.image),
//             child: const ResolveRedFlagView(),
//           );
//         } else {
//           return const Scaffold();
//         }
//       },
//     );
//   }
// }
