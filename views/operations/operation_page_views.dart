import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/views/excel_produce_view.dart';
import 'package:electricity_plus/views/operations/add_customer/add_customer_view.dart';
import 'package:electricity_plus/views/operations/add_customer/bloc/add_customer_bloc.dart';
import 'package:electricity_plus/views/operations/admin/bloc/admin_bloc.dart';
import 'package:electricity_plus/views/operations/admin/admin_view.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bloc/bill_receipt_bloc.dart';
import 'package:electricity_plus/views/operations/printer_select_view.dart';
import 'package:electricity_plus/views/operations/customer_search/bloc/customer_search_bloc.dart';
import 'package:electricity_plus/views/operations/price_setting/bloc/set_price_bloc.dart';
import 'package:electricity_plus/views/operations/resolve_issue/bloc/resolve_issue_bloc.dart';
import 'package:electricity_plus/views/operations/town_selection/town_selection_frame.dart';
import 'package:electricity_plus/views/operations/flagged_customer_search.dart';
import 'package:electricity_plus/views/operations/customer_search/electric_log_search_view.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/views/operations/customer_receipt_history_list_view.dart';
import 'package:electricity_plus/views/operations/home_page_view.dart';
import 'package:electricity_plus/views/operations/initialise_data_view.dart';
import 'package:electricity_plus/views/operations/bill_receipt/bill_view.dart';
import 'package:electricity_plus/views/operations/resolve_issue_view.dart';
import 'package:electricity_plus/views/operations/price_setting/set_price_view.dart';
import 'package:electricity_plus/views/operations/town_selection/bloc/town_selection_bloc.dart';
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
        }
      },
      builder: (context, state) {
        if (state is OperationStateDefault) {
          return const HomePageView();
        } else if (state is OperationStateGeneratingBill) {
          return BlocProvider(
            create: (context) => BillReceiptBloc(FirebaseCloudStorage())
              ..add(BillInitialise(
                  customer: state.customer, history: state.history)),
            child: const BillView(),
          );
        } else if (state is OperationStateSettingPrice) {
          return BlocProvider(
            create: (context) => SetPriceBloc(FirebaseCloudStorage())
              ..add(const SetPriceEventInitialise()),
            child: const SetPriceView(),
          );
        } else if (state is OperationStateElectricLogSearch) {
          return BlocProvider(
            create: (context) => CustomerSearchBloc(FirebaseCloudStorage()),
            child: const ElectricLogSearchView(),
          );
        } else if (state is OperationStateFetchingCustomerHistory) {
          return const CustomerHistoryList();
        } else if (state is OpeartionStateFlagCustomerSearch) {
          return const FlaggedCustomerSearchView();
        } else if (state is OperationStateResolveIssue) {
          return BlocProvider(
            create: (context) => ResolveIssueBloc(FirebaseCloudStorage()),
            child: const ResolveIssueView(),
          );
        } else if (state is OperationStateAddCustomer) {
          return BlocProvider(
            create: (context) => AddCustomerBloc(FirebaseCloudStorage()),
            child: const AddCustomerView(),
          );
        } else if (state is OperationStateAdminView) {
          return BlocProvider(
            create: (context) => AdminBloc(FirebaseCloudStorage())
              ..add(const AdminEventCheckAuthorisation()),
            child: const AdminView(),
          );
        } else if (state is OperationStateInitialiseData) {
          return const InitialiseDataView();
        } else if (state is OperationStateProduceExcel) {
          return const ProduceExcelView();
        } else if (state is OperationStateChooseTown) {
          return BlocProvider<TownSelectionBloc>(
            create: (context) => TownSelectionBloc(FirebaseCloudStorage())
              ..add(const TownSelectionInitialise()),
            child: const TownSelectionFrame(),
          );
        } else if (state is OperationStateChooseBluetooth) {
          return BlocProvider(
            create: (context) => BillReceiptBloc(FirebaseCloudStorage()),
            child: const PrinterSelectView(),
          );
        } else if (state is OperationStatePayment) {
          return BlocProvider(
            create: (context) => BillReceiptBloc(FirebaseCloudStorage())
              ..add(BillQrInitialise(qrCode: state.qrCode)),
            child: const BillView(),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
