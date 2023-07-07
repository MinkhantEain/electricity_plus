import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
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
          customer: flaggedCustomers,
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

    // on<FlaggedEventBlack>(
    //   (event, emit) {
    //     emit(const FlaggedStateLoading());
    //     emit(const FlaggedStatePageSelected(
    //       customer: customer,
    //       onTap: onTap,
    //       pageName: 'Unpaid Customer',
    //     ));
    //   },
    // );
  }
}
