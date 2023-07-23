import 'package:date_time_picker/date_time_picker.dart';
import 'package:electricity_plus/views/operations/management/bloc/admin_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MonthlyTotalView extends StatelessWidget {
  const MonthlyTotalView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminStateMonthlyTotal) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Monthly Total'),
              leading: BackButton(
                onPressed: () =>
                    context.read<AdminBloc>().add(const AdminEventAdminView()),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width/2,
                    child: DateTimePicker(
                      icon: const Icon(Icons.date_range_outlined),
                      initialValue: state.date,
                      type: DateTimePickerType.date,
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                      dateMask: 'MM, yyyy',
                      firstDate: DateTime(1990, 1, 1),
                      lastDate: DateTime.now(),
                      initialDate: DateTime.now(),
                      onChanged: (value) {
                        context.read<AdminBloc>().add(AdminEventMonthlyTotal(date: value.substring(0, 7)));
                      },
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Text('Total Read Meters: ${state.totalCustomers}'),
                  Text('Total Exchange Meter: ${state.totalExchangeMeters}'),
                  const Divider(height: 20,),
                  Text('Total Used Units: ${state.totalUnitUsed}'),
                  Text('Total Allowed Units: ${state.totalAllowedUnits}'),
                  const Divider(height: 20,),
                  Text('Total Collected Amount: ${state.collectedAmount}'),
                  Text('Total Unpaid Amount: ${state.unpaidAmount}'),
                  Text('Total Unpaid Customers: ${state.unpaidCustomers}'),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
