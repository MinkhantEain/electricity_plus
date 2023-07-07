part of 'flagged_bloc.dart';

typedef ContextualCallBack = void Function(
  BuildContext context,
  CloudCustomer customer,
);

abstract class FlaggedState extends Equatable {
  const FlaggedState();

  @override
  List<Object> get props => [];
}

class FlaggedInitial extends FlaggedState {
  const FlaggedInitial();
}

class FlaggedStateLoading extends FlaggedState {
  const FlaggedStateLoading();
}

class FlaggedStateRedSelected extends FlaggedState {
  final CloudCustomer customer;
  final CloudFlag flag;
  final Uint8List? image;
  const FlaggedStateRedSelected({
    required this.customer,
    required this.flag,
    required this.image,
  });
}

class FlaggedStatePageSelected extends FlaggedState {
  final Iterable<CloudCustomer> customer;
  final ContextualCallBack onTap;
  final String pageName;
  const FlaggedStatePageSelected({
    required this.customer,
    required this.onTap,
    required this.pageName,
  });
}
