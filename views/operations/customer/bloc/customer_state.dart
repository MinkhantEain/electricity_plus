// part of 'customer_bloc.dart';

// abstract class CustomerState extends Equatable {
//   const CustomerState();

//   @override
//   List<Object> get props => [];
// }

// class CustomerStateInitial extends CustomerState {
//   final CloudCustomer customer;
//   const CustomerStateInitial(this.customer);
// }

// class CustomerStateLoading extends CustomerState {
//   const CustomerStateLoading();
// }

// class CustomerStateElectricLog extends CustomerState {
//   final num previousUnit;
//   final CloudCustomer customer;
//   const CustomerStateElectricLog(this.customer, this.previousUnit);
//   @override
//   List<Object> get props => [super.props, previousUnit];
// }

// class CustomerStateLogHistory extends CustomerState {
//   final CloudCustomer customer;
//   final Iterable<CloudCustomerHistory> historyList;
//   const CustomerStateLogHistory({
//     required this.historyList,
//     required this.customer,
//   });
// }

// class CustomerStateResolveIssue extends CustomerState {
//   final CloudCustomer customer;
//   final CloudFlag flag;
//   final Uint8List? image;
//   const CustomerStateResolveIssue(
//       {required this.customer, required this.flag, required this.image});
// }
