import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/views/excel_produce_view.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/bill_bloc.dart';

import 'package:electricity_plus/views/operations/flagged/bloc/flagged_bloc.dart';
import 'package:electricity_plus/views/operations/flagged/flagged_view.dart';
import 'package:electricity_plus/views/operations/management/add_customer/add_customer_view.dart';
import 'package:electricity_plus/views/operations/management/add_customer/bloc/add_customer_bloc.dart';
import 'package:electricity_plus/views/operations/management/admin_view.dart';
import 'package:electricity_plus/views/operations/management/bloc/admin_bloc.dart';
import 'package:electricity_plus/views/operations/management/import_data/bloc/import_data_bloc.dart';
import 'package:electricity_plus/views/operations/management/price_setting/bloc/set_price_bloc.dart';
import 'package:electricity_plus/views/operations/management/price_setting/set_price_view.dart';
import 'package:electricity_plus/views/operations/customer_search/bloc/customer_search_bloc.dart';
import 'package:electricity_plus/views/operations/customer_search/customer_search_view.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/views/operations/home_page_view.dart';
import 'package:electricity_plus/views/operations/management/import_data/import_data_view.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bill_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OperationPageViews extends StatefulWidget {
  const OperationPageViews({super.key});

  @override
  State<OperationPageViews> createState() => _OperationPageViewsState();
}

class _OperationPageViewsState extends State<OperationPageViews> {
  String townName = '';
  @override
  Widget build(BuildContext context) {
    context.read<OperationBloc>().add(const OperationEventDefault());
    return BlocConsumer<OperationBloc, OperationState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'Plase wait a moment');
        } else {
          LoadingScreen().hide();
          if (state is OperationStatePayment) {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => BillBloc(
                          provider: FirebaseCloudStorage())
                        ..add(BillEventQrCodeInitialise(qrCode: state.qrCode)),
                      child: const BillView(),
                    ),
                  ),
                )
                .then((value) => context
                    .read<OperationBloc>()
                    .add(const OperationEventDefault()));
          }
        }
      },
      builder: (context, state) {
        if (state is OperationStateDefault) {
          return const HomePageView();
          // } else if (state is OperationStateGeneratingBill) {
          //   return BlocProvider(
          //     create: (context) => BillBloc(provider: FirebaseCloudStorage())
          //       ..add(BillEventInitialise(
          //         customer: state.customer,
          //         customerHistory: state.history,
          //       )),
          //     child: const BillView(),
          //   );
        } else if (state is OperationStateSettingPrice) {
          return BlocProvider(
            create: (context) => SetPriceBloc(FirebaseCloudStorage())
              ..add(const SetPriceEventInitialise()),
            child: const SetPriceView(),
          );
        } else if (state is OperationStateBillHistory) {
          return BlocProvider(
            create: (context) => CustomerSearchBloc(FirebaseCloudStorage())
              ..add(const CustomerSearchBillHistorySearchInitialise()),
            child: const CustomerSearchView(),
          );
        } else if (state is OperationStateElectricLogSearch) {
          return BlocProvider(
            create: (context) => CustomerSearchBloc(FirebaseCloudStorage())
              ..add(const CustomerSearchMeterReadSearchInitialise()),
            child: const CustomerSearchView(),
          );
        } else if (state is OperationStateAddCustomer) {
          return BlocProvider(
            create: (context) => AddCustomerBloc(FirebaseCloudStorage()),
            child: const AddCustomerView(),
          );
        } else if (state is OperationStateAdminView) {
          return BlocProvider(
            create: (context) => AdminBloc(FirebaseCloudStorage(), state.userType),
            child: const AdminView(),
          );
        } else if (state is OperationStateInitialiseData) {
          return BlocProvider(
            create: (context) => ImportDataBloc(FirebaseCloudStorage()),
            child: const ImportDataView(),
          );
        } else if (state is OperationStateProduceExcel) {
          return const ProduceExcelView();
        } else if (state is OperationStateFlagged) {
          return BlocProvider(
            create: (context) => FlaggedBloc(FirebaseCloudStorage()),
            child: const FlaggedView(),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
