import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/services/models/cloud_flag.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'flagged_event.dart';
part 'flagged_state.dart';

class FlaggedBloc extends Bloc<FlaggedEvent, FlaggedState> {
  FlaggedBloc(FirebaseCloudStorage provider) : super(const FlaggedInitial()) {
    on<FlaggedEvent>((event, emit) {});

    on<FlaggedEventInitial>(
      (event, emit) {
        emit(const FlaggedStateLoading());
        emit(const FlaggedInitial());
      },
    );

    on<FlaggedEventRed>(
      (event, emit) async {
        emit(const FlaggedStateLoading());
        //fetch

        final flaggedCustomers = await provider.allFlaggedCustomer();

        emit(FlaggedStatePageSelected(
          customers: flaggedCustomers,
          onTap: (context, customer) {
            context.read<FlaggedBloc>().add(
                  FlaggedEventRedSelect(
                    customer: customer,
                  ),
                );
          },
          pageName: 'Error Meter',
        ));
      },
    );

    on<FlaggedEventRedSelect>(
      (event, emit) async {
        emit(const FlaggedStateLoading());
        final flag = await provider.getFlaggedIssue(customer: event.customer);
        final image = await provider.getImage(flag.imageUrl);
        emit(
          FlaggedStateRedSelected(
              customer: event.customer, flag: flag, image: image),
        );
      },
    );

    on<FlaggedEventBlackSelect>(
      (event, emit) async {
        emit(const FlaggedStateLoading());
        final history = await provider.getUnpaidBill(customer: event.customer);
        emit(FlaggedStateBlackSelected(
          customer: event.customer,
          history: history,
        ));
      },
    );

    on<FlaggedEventUnreadCustomers>(
      (event, emit) async {
        emit(const FlaggedStateLoading());
        late final Iterable<CloudCustomer> customers;
        if (event.customers != null) {
          customers = event.customers!;
        } else {
          customers = await provider.getUnreadCustomer();
        }
        emit(FlaggedStatePageSelected(
          customers: customers,
          onTap: (context, customer) {
            context.read<FlaggedBloc>().add(FlaggedEventUnreadCustomersSelect(
                customer: customer, customers: customers));
          },
          pageName: 'Unread Customers',
        ));
      },
    );

    on<FlaggedEventUnreadCustomersSelect>(
      (event, emit) async {
        emit(const FlaggedStateLoading());
        emit(FlaggedStateUnreadCustomerSelected(
            customers: event.customers,
            customer: event.customer,
            previousReading:
                (await provider.getPreviousValidUnit(event.customer))
                    .toString()));
      },
    );

    on<FlaggedEventBillSelect>(
      (event, emit) async {
        emit(const FlaggedStateLoading());
        emit(FlaggedStateBillSelected(
          customer: event.customer,
          historyList: await provider.getRecentBillHistory(
            customer: event.customer,
            upperDateThreshold: event.history.date,
          ),
          history: event.history,
        ));
        emit(event.currentState);
      },
    );

    on<FlaggedEventBlack>(
      (event, emit) async {
        emit(const FlaggedStateLoading());
        final customers = await provider.allInDebtCustomer();
        emit(FlaggedStatePageSelected(
          customers: customers,
          onTap: (context, customer) {
            context.read<FlaggedBloc>().add(FlaggedEventBlackSelect(
                  customer: customer,
                ));
          },
          pageName: 'Unpaid Customers',
        ));
      },
    );
  }
}
