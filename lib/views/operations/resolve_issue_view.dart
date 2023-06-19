import 'package:electricity_plus/services/cloud/cloud_storage_exceptions.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResolveIssueView extends StatefulWidget {
  const ResolveIssueView({super.key});

  @override
  State<ResolveIssueView> createState() => _ResolveIssueViewState();
}

class _ResolveIssueViewState extends State<ResolveIssueView> {
  late final TextEditingController _commentTextController;

  @override
  void initState() {
    _commentTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperationBloc, OperationState>(
      listener: (context, state) async {
        if (state is OperationStateResolveIssue) {
          if (state.exception is UnableToUpdateException) {
            await showErrorDialog(context, 'Error: Could not update!');
          } else if (state.resolved) {
            await showGenericDialog(
              context: context,
              title: 'Issue',
              content: "The Issue has been resolved.",
              optionsBuilder: () => {
                'OK': null,
              },
            ).then((value) => context.read<OperationBloc>().add(const OperationEventDefault()));
          }
        }
      },
      builder: (context, state) {
        if (state is OperationStateResolveIssue) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Issue'),
              leading: BackButton(
                onPressed: () {
                  context.read<OperationBloc>().add(
                        const OperationEventFlagCustomerSearch(
                            isSearching: false, userInput: ''),
                      );
                },
              ),
            ),
            body: Column(
              children: [
                Text('Date: ${state.date}'),
                Text('Latest Information: ${state.previousComment}'),
                TextField(
                  controller: _commentTextController,
                  decoration: const InputDecoration(hintText: 'Comment...'),
                  minLines: 3,
                  maxLines: 3,
                ),
                ElevatedButton(
                    onPressed: () {
                      context.read<OperationBloc>().add(
                          OperationEventResolveIssue(
                              customer: state.customer,
                              resolved: true,
                              newComment: _commentTextController.text));
                    },
                    child: const Text('Resolve')),
              ],
            ),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
