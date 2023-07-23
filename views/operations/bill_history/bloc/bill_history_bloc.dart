import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/services/models/cloud_customer_history.dart';
import 'package:equatable/equatable.dart';

part 'bill_history_event.dart';
part 'bill_history_state.dart';

class BillHistoryBloc extends Bloc<BillHistoryEvent, BillHistoryState> {
  BillHistoryBloc({
    required Iterable<CloudCustomerHistory> historyList,
    required CloudCustomer customer,
  }) : super(BillHistoryStateInitial(
          historyList: historyList,
          customer: customer,
        )) {

    on<BillHistoryEventSelect>((event, emit) async {
      emit(BillHistoryStateLoading(historyList: historyList));
      emit(BillHistoryStateSelected(
          history: event.history,
          customer: event.customer,
          historyList: historyList));
      emit(event.currentState);
    });

    on<BillHistoryEventEmitState>(
      (event, emit) => emit(event.currentState),
    );
  }
}
