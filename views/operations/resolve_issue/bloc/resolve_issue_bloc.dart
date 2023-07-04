import 'package:bloc/bloc.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:equatable/equatable.dart';

part 'resolve_issue_event.dart';
part 'resolve_issue_state.dart';

class ResolveIssueBloc extends Bloc<ResolveIssueEvent, ResolveIssueState> {
  ResolveIssueBloc(FirebaseCloudStorage provider) : super(ResolveIssueInitial()) {
    on<ResolveIssueEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
