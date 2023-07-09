import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:equatable/equatable.dart';

part 'set_price_event.dart';
part 'set_price_state.dart';

class SetPriceBloc extends Bloc<SetPriceEvent, SetPriceState> {
  SetPriceBloc(FirebaseCloudStorage provider)
      : super(const SetPriceStateUninitialised()) {
    on<SetPriceEventInitialise>((event, emit) async {
      emit(const SetPriceStateLoading());
      try {
        final priceDoc = await provider.getAllPrices();
        emit(SetPriceStateLoaded(
            price: priceDoc.pricePerUnit,
            horsePowerPerUnitCost: priceDoc.horsePowerPerUnitCost,
            roadLightPrice: priceDoc.roadLightPrice,
            serviceCharge: priceDoc.serviceCharge));
      } on NoSuchDocumentException {
        emit(const SetPriceStateNoPriceDocFoundError());
      }
    });

    on<SetPriceEventSubmit>((event, emit) async {
      emit(const SetPriceStateLoading());
      //check password if its correct
      if (await provider.verifyPassword(event.password)) {
        try {
          final price = event.newPrice;
          final serviceCharge = event.serviceCharge;
          final horsePowerPerUnitCost = event.horsePowerPerUnitCost;
          final roadLightPrice = event.roadLightPrice;

          if (price.isNotEmpty) {
            await provider.setPrice(
              newPrice: price,
              token: event.password,
              priceChangeField: pricePerUnitField,
            );
          }
          if (serviceCharge.isNotEmpty) {
            await provider.setPrice(
              newPrice: serviceCharge,
              token: event.password,
              priceChangeField: serviceChargeField,
            );
          }
          if (horsePowerPerUnitCost.isNotEmpty) {
            await provider.setPrice(
              newPrice: horsePowerPerUnitCost,
              token: event.password,
              priceChangeField: horsePowerPerUnitCostField,
            );
          }

          if (roadLightPrice.isNotEmpty) {
            await provider.setPrice(
              newPrice: roadLightPrice,
              token: event.password,
              priceChangeField: roadLightPriceField,
            );
          }
          emit(SetPriceStateLoaded(
              price: (await provider.getPrice()),
              horsePowerPerUnitCost: await provider.getHorsePowerPerUnitCost(),
              roadLightPrice: await provider.getRoadLightPrice(),
              serviceCharge: await provider.getServiceCharge()));
        } on CouldNotSetPriceException {
          emit(const SetPriceStateInvalidValueError());
          emit(SetPriceStateLoaded(
              price: (await provider.getPrice()),
              horsePowerPerUnitCost: await provider.getHorsePowerPerUnitCost(),
              roadLightPrice: await provider.getRoadLightPrice(),
              serviceCharge: await provider.getServiceCharge()));
        }
      } else {
        emit(const SetPriceStateInvalidPassowrd());
        emit(SetPriceStateLoaded(
            price: (await provider.getPrice()),
            horsePowerPerUnitCost: await provider.getHorsePowerPerUnitCost(),
            roadLightPrice: await provider.getRoadLightPrice(),
            serviceCharge: await provider.getServiceCharge()));
      }
    });
  }
}
