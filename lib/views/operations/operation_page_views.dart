import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/views/excel_produce_view.dart';
import 'package:electricity_plus/views/operations/add_customer_view.dart';
import 'package:electricity_plus/views/operations/admin_view.dart';
import 'package:electricity_plus/views/operations/choose_town_view.dart';
import 'package:electricity_plus/views/operations/flagged_customer_search.dart';
import 'package:electricity_plus/views/operations/image_comment_view.dart';
import 'package:electricity_plus/views/operations/electric_log_search_view.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/views/operations/create_new_electric_log_view.dart';
import 'package:electricity_plus/views/operations/customer_receipt_history_list_view.dart';
import 'package:electricity_plus/views/operations/customer_receipt_search_view.dart';
import 'package:electricity_plus/views/operations/home_page_view.dart';
import 'package:electricity_plus/views/operations/initialise_data_view.dart';
import 'package:electricity_plus/views/operations/receipt_view.dart';
import 'package:electricity_plus/views/operations/resolve_issue_view.dart';
import 'package:electricity_plus/views/operations/set_price_view.dart';
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
        } else if (state is OperationStateSearchingCustomerReceipt) {
          return const CustomerSearchView();
        } else if (state is OperationStateGeneratingReceipt) {
          return const ReceiptView();
        } else if (state is OperationStateSettingPrice) {
          return const SetPriceView();
        } else if (state is OperationStateElectricLogSearch) {
          return const ElectricLogSearchView();
        } else if (state is OperationStateFetchingCustomerReceiptHistory) {
          return const CustomerReceiptHistoryList();
        } else if (state is OperationStateCreatingNewElectricLog) {
          return const CreateElectricLogView();
        } else if (state is OperationStateImageCommentFlag) {
          return const ImageCommentFlagView();
        } else if (state is OpeartionStateFlagCustomerSearch) {
          return const FlaggedCustomerSearchView();
        } else if (state is OperationStateResolveIssue) {
          return const ResolveIssueView();
        } else if (state is OperationStateAddCustomer) {
          return const AddCustomerView();
        } else if (state is OperationStateAdminView) {
          return const AdminView();
        } else if (state is OperationStateInitialiseData) {
          return const InitialiseDataView();
        } else if (state is OperationStateProduceExcel) {
          return const ProduceExcelView();
        } else if (state is OperationStateChooseTown){
          return const ChooseTownView();
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
