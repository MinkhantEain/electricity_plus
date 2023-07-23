import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_flag.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

part 'resolve_red_flag_event.dart';
part 'resolve_red_flag_state.dart';

class ResolveRedFlagBloc
    extends Bloc<ResolveRedFlagEvent, ResolveRedFlagState> {
  ResolveRedFlagBloc(
    FirebaseCloudStorage provider, {
    required CloudCustomer customer,
    required CloudFlag flag,
    required Uint8List? image,
  }) : super(ResolveRedFlagInitial(
          customer: customer,
          flag: flag,
          image: image,
        )) {
    on<ResolveRedFlagEvent>((event, emit) {
      
    });

    on<ResolveRedFlagEventResolve>((event, emit) async {
      emit(const ResolveRedFlagStateLoading());
      try {
        await provider.resolveRedFlag(
            customer: customer, comment: event.newComment);
        emit(const ResolveRedFlagStateResolved());
      } on UnableToCreateResolveDocException {
        emit(const ResolveRedFlagUnableToCreateIssue());
        ResolveRedFlagInitial(
          customer: customer,
          flag: flag,
          image: image,
        );
      } on UnableToUpdateCustomerDocFlagException {
        emit(const ResolveRedFlagCustomerUpdateFailure());
        ResolveRedFlagInitial(customer: customer, flag: flag, image: image);
      }
    });
  }
}
