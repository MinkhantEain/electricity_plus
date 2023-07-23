import 'package:date_time_picker/date_time_picker.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/views/operations/management/app_user/app_user_history/bloc/app_user_history_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppUserHistoryStaffView extends StatefulWidget {
  const AppUserHistoryStaffView({
    super.key,
  });

  @override
  State<AppUserHistoryStaffView> createState() =>
      _AppUserHistoryStaffViewState();
}

class _AppUserHistoryStaffViewState extends State<AppUserHistoryStaffView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUserHistoryBloc, AppUserHistoryState>(
      builder: (context, state) {
        if (state is AppUserHistoryStateSelected) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.staff.name),
              leading: BackButton(
                onPressed: () {
                  context
                      .read<AppUserHistoryBloc>()
                      .add(AppUserHistoryEventStaffListView(
                        staffList: state.staffList,
                      ));
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  RadioListTile(
                    value: meterReaderType,
                    groupValue: state.radioState,
                    title: const Text('Meter Reader'),
                    onChanged: (value) => setState(() {
                      context.read<AppUserHistoryBloc>().add(
                          AppUserHistoryEventChangeRadioState(
                              appUserHistoryState: state,
                              radioState: value ?? state.staff.userType));
                    }),
                  ),
                  RadioListTile(
                    value: cashierType,
                    groupValue: state.radioState,
                    title: const Text('Cashier'),
                    onChanged: (value) => setState(
                      () {
                        context.read<AppUserHistoryBloc>().add(
                            AppUserHistoryEventChangeRadioState(
                                appUserHistoryState: state,
                                radioState: value ?? state.staff.userType));
                      },
                    ),
                  ),
                  DateTimePicker(
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900, 1, 1, 0, 0),
                    lastDate: DateTime.now(),
                    calendarTitle: 'Choose the date',
                    dateHintText: 'Choose date',
                    onChanged: (newValue) {
                      if (state.radioState == cashierType) {
                        context.read<AppUserHistoryBloc>().add(
                              AppUserHistoryEventGetCashierHistory(
                                  staff: state.staff,
                                  date: newValue,
                                  staffList: state.staffList),
                            );
                      } else {
                        context.read<AppUserHistoryBloc>().add(
                              AppUserHistoryEventGetMeterReaderHistory(
                                  staff: state.staff,
                                  date: newValue,
                                  staffList: state.staffList),
                            );
                      }
                    },
                  ),
                  Visibility(
                    visible: state.radioState == meterReaderType,
                    child: Column(
                      children: [
                        Text('Total Read Meter: ${state.meterStats}'),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: state.radioState == cashierType,
                    child: Column(
                      children: [
                        Text('Total money collected: ${state.receiptStats}')
                      ],
                    ),
                  ),
                  Visibility(
                    visible: state.radioState == meterReaderType,
                    child: Column(
                      children: [
                        for (final element in state.history)
                          ListTile(
                            title: Column(
                              children: [
                                Text(element.name),
                                Text(element.bookId),
                                Visibility(
                                    visible: state.staff.name == 'Daily Total',
                                    child: Text(element.inspector)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: state.radioState == cashierType,
                    child: Column(
                      children: [
                        for (final element in state.receipt)
                          ListTile(
                            title: Column(
                              children: [
                                Text(element.customerName),
                                Text(element.bookId),
                                Text(element.cost.toString()),
                                Visibility(
                                  visible: state.staff.name == 'Daily Total',
                                  child: Text(element.collectorName),
                                )
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
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
