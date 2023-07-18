import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:electricity_plus/services/models/exchange_model.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'exchange_meter_event.dart';
part 'exchange_meter_state.dart';

class ExchangeMeterBloc extends Bloc<ExchangeMeterEvent, ExchangeMeterState> {
  ExchangeMeterBloc({
    required FirebaseCloudStorage provider,
    required CloudCustomer customer,
  }) : super(ExchangeMeterStateInitial(customer: customer)) {
    on<ExchangeMeterEventSubmit>((event, emit) async {
      emit(const ExchangeMeterStateLoading());
      //gets the details
      final calculationDetails = event.calculationDetails;
      final cost = num.parse(event.cost);
      final exchangeReason = event.exchangeReason;
      final initialMeterReading = num.parse(event.initialMeterReading);
      final newMeterCost = num.parse(event.newMeterCost);
      final newMeterId = event.newMeterId;
      final newUnit = num.parse(event.newUnit);
      final previousUnit = num.parse(event.previousUnit);
      final totalCost = num.parse(event.totalCost);
      final unitUsed = num.parse(event.unitUsed);

      //creates an exchange history for records
      final exchangeHistory = CloudExchangeHistory(
        documentId: '',
        address: customer.address,
        bookId: customer.bookId,
        date: DateTime.now().toString(),
        tempBookId: getTempBookId(customer.bookId),
        oldMeterId: customer.meterId,
        newMeterId: newMeterId,
        name: customer.name,
        exchangeReason: exchangeReason,
        previousUnit: previousUnit,
        finalUnit: newUnit,
        unitUsed: unitUsed,
        calculationDetails: calculationDetails,
        cost: cost,
        newMeterInitialReading: initialMeterReading,
        costOfNewMeter: newMeterCost,
        totalCost: totalCost,
      );

      //creates a temporary customer
      final tempCustomer = CloudCustomer(
        documentId: bookIdToDocId(getTempBookId(customer.bookId)),
        bookId: getTempBookId(customer.bookId),
        meterId: customer.meterId,
        name: customer.name,
        address: customer.address,
        lastUnit: customer.lastUnit,
        flag: false,
        lastReadDate: DateTime.now().toString(),
        debt: 0,
        adder: 0,
        horsePowerUnits: customer.horsePowerUnits,
        meterMultiplier: customer.meterMultiplier,
        hasRoadLightCost: customer.hasRoadLightCost,
        lastHistory: customer.lastHistory,
      );

      //creates a history for exchange meter for temp customer
      final exchangeBill = CloudCustomerHistory(
        documentId: '',
        previousUnit: previousUnit,
        newUnit: previousUnit+unitUsed,
        priceAtm: 0,
        cost: 0,
        date: DateTime.now().toString(),
        imageUrl:
            'https://firebasestorage.googleapis.com/v0/b/electricityplus-a6572.appspot.com/o/newUser%2Fptc%20black%20logo%20png.png?alt=media&token=5352fbb9-6396-4f71-af86-5d975c7fc20a',
        comment: '$exchangeReason\n$calculationDetails',
        isVoided: false,
        paidAmount: 0,
        inspector: FirebaseAuth.instance.currentUser!.displayName!,
        isPaid: true,
        serviceChargeAtm: 0,
        horsePowerPerUnitCostAtm: 0,
        horsePowerUnits: 0,
        meterMultiplier: 0,
        roadLightPrice: 0,
        meterAllowance: 0,
      );

      //creates new actual customer
      final actualCustomer = CloudCustomer(
        documentId: customer.documentId,
        bookId: customer.bookId,
        meterId: newMeterId,
        name: customer.name,
        address: customer.address,
        lastUnit: initialMeterReading,
        flag: false,
        lastReadDate: DateTime.now().toString(),
        debt: customer.debt + totalCost,
        adder: customer.adder,
        horsePowerUnits: customer.horsePowerUnits,
        meterMultiplier: customer.meterMultiplier,
        hasRoadLightCost: customer.hasRoadLightCost,
        lastHistory: customer.lastHistory,
      );

      //creates a blank history
      final blankHistory = CloudCustomerHistory(
        documentId: '',
        previousUnit: initialMeterReading,
        newUnit: initialMeterReading,
        priceAtm: 0,
        cost: totalCost,
        date: DateTime.now().toString(),
        imageUrl:
            'https://firebasestorage.googleapis.com/v0/b/electricityplus-a6572.appspot.com/o/newUser%2Fptc%20black%20logo%20png.png?alt=media&token=5352fbb9-6396-4f71-af86-5d975c7fc20a',
        comment: 'Change Meter',
        isVoided: false,
        paidAmount: 0,
        inspector: FirebaseAuth.instance.currentUser!.displayName!,
        isPaid: false,
        serviceChargeAtm: 0,
        horsePowerPerUnitCostAtm: 0,
        horsePowerUnits: 0,
        meterMultiplier: 0,
        roadLightPrice: 0,
        meterAllowance: 0,
      );

      final submissionResult = await provider.exchangeMeterSubmission(
        actualCustomer: actualCustomer,
        tempCustomer: tempCustomer,
        blankBill: blankHistory,
        exchangeBill: exchangeBill,
        exchangeHistory: exchangeHistory,
      );

      emit(ExchangeMeterStateSubmitted(customer: submissionResult[0],
      history: submissionResult[2]));
    });
  }
}
