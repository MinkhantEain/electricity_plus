import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/views/operations/customer_search_view.dart';
import 'package:electricity_plus/views/operations/home_page_view.dart';
import 'package:electricity_plus/views/operations/receipt_view.dart';
import 'package:electricity_plus/views/operations/set_price_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OperationPageViews extends StatelessWidget {
  const OperationPageViews({super.key});

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
        } else if (state is OperationStateSearchingCustomer) {
          return const CustomerSearchView();
        } else if (state is OperationStateGeneratingReceipt) {
          return const ReceiptView();
        } else if (state is OperationStateSettingPrice) {
          return const SetPriceView();
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
