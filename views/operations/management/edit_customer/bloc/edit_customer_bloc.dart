import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:equatable/equatable.dart';

part 'edit_customer_event.dart';
part 'edit_customer_state.dart';

class EditCustomerBloc extends Bloc<EditCustomerEvent, EditCustomerState> {
  EditCustomerBloc(FirebaseCloudStorage provider, CloudCustomer customer)
      : super(EditCustomerInitial(customer: customer)) {

    on<EditCustomerEventSubmit>((event, emit) async {
      emit(const EditCustomerStateLoading());
      customer = customer.editCustomer(
        newName: event.name,
        newHorsePowerUnits: num.parse(event.horsePowerUnits),
        newMeterMultiplier: num.parse(event.meterMultiplier),
        newHasRoadLightCost: event.hasRoadLightCost,
      );
      await provider.editCustomerDetails(updatedCustomer: customer);
      emit(const EditCustomerStateSubmitted());
      emit(EditCustomerInitial(customer: customer));
    });


  }
}
