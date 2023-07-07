part of 'resolve_red_flag_bloc.dart';

abstract class ResolveRedFlagEvent extends Equatable {
  const ResolveRedFlagEvent();

  @override
  List<Object> get props => [];
}

class ResolveRedFlagEventResolve extends ResolveRedFlagEvent {
  final String newComment;
  const ResolveRedFlagEventResolve({required this.newComment});
}