import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProduceExcelView extends StatelessWidget {
  const ProduceExcelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.read<OperationBloc>().add(const OperationEventAdminView());
          },
        ),
        title: const Text('Produce Excel'),
      ),
    );
  }
}
