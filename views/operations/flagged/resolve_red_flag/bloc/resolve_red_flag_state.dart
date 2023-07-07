part of 'resolve_red_flag_bloc.dart';

abstract class ResolveRedFlagState extends Equatable {
  const ResolveRedFlagState();
  
  @override
  List<Object> get props => [];
}

class ResolveRedFlagInitial extends ResolveRedFlagState {
  final CloudFlag flag;
  final CloudCustomer customer;
  final Uint8List? image;
  const ResolveRedFlagInitial({
    required this.customer,
    required this.flag,
    required this.image,
  });
}


class ResolveRedFlagStateLoading extends ResolveRedFlagState {
  const ResolveRedFlagStateLoading();
}

class ResolveRedFlagStateError extends ResolveRedFlagState {
  const ResolveRedFlagStateError();
}


class ResolveRedFlagUnableToCreateIssue extends ResolveRedFlagStateError {
  const ResolveRedFlagUnableToCreateIssue();
}

class ResolveRedFlagCustomerUpdateFailure extends ResolveRedFlagStateError {
  const ResolveRedFlagCustomerUpdateFailure();
}

class ResolveRedFlagStateResolved extends ResolveRedFlagState {
  const ResolveRedFlagStateResolved();
}