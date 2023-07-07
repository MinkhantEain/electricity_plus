// import 'package:bloc/bloc.dart';
// import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
// import 'package:electricity_plus/services/models/cloud_customer.dart';
// import 'package:electricity_plus/services/models/cloud_customer_history.dart';
// import 'package:electricity_plus/services/models/cloud_flag.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/services.dart';

// part 'customer_event.dart';
// part 'customer_state.dart';

// class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
//   CustomerBloc(CloudCustomer customer) : super(CustomerStateInitial(customer)) {
//     on<CustomerEventELectricLog>(
//       (event, emit) async {
//         emit(const CustomerStateLoading());
//         emit(CustomerStateElectricLog(customer,
//             await FirebaseCloudStorage().getPreviousValidUnit(customer)));
//       },
//     );

//     on<CustomerEventReinitialise>(
//       (event, emit) {
//         emit(const CustomerStateLoading());
//         emit(CustomerStateInitial(customer));
//       },
//     );

//     on<CustomerEventResolveIssue>(
//       (event, emit) async {
//         emit(const CustomerStateLoading());
//         final flag = await FirebaseCloudStorage()
//               .getFlaggedIssue(customer: customer);
//         final image = await FirebaseCloudStorage().getImage(flag.imageUrl);
//         emit(CustomerStateResolveIssue(
//           customer: customer,
//           flag: flag, image: image,
//         ));
//       },
//     );

//     on<CustomerEventLogHistory>(
//       (event, emit) async {
//         emit(const CustomerStateLoading());
//         final historyList = await FirebaseCloudStorage().getCustomerAllHistory(customer: customer);
//         emit(CustomerStateLogHistory(historyList: historyList, customer: customer));
//       },
//     );
//   }
// }
