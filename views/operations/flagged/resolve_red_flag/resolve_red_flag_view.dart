import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/generic_dialog.dart';
import 'package:electricity_plus/views/operations/flagged/bloc/flagged_bloc.dart';
import 'package:electricity_plus/views/operations/flagged/resolve_red_flag/bloc/resolve_red_flag_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResolveRedFlagView extends StatefulWidget {
  const ResolveRedFlagView({super.key});

  @override
  State<ResolveRedFlagView> createState() => _ResolveRedFlagViewState();
}

class _ResolveRedFlagViewState extends State<ResolveRedFlagView> {
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
    return BlocConsumer<ResolveRedFlagBloc, ResolveRedFlagState>(
      listener: (context, state) async {
        if (state is ResolveRedFlagStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is ResolveRedFlagUnableToCreateIssue) {
            await showErrorDialog(context, 'Error: Could not create an issue!');
          } else if (state is ResolveRedFlagCustomerUpdateFailure) {
            await showErrorDialog(
                context, 'Error: Could not update flag field!');
          } else if (state is ResolveRedFlagStateResolved) {
            await showGenericDialog(
              context: context,
              title: 'Issue',
              content: "The Issue has been resolved.",
              optionsBuilder: () => {
                'OK': null,
              },
            ).then((value) async {
              context.read<OperationBloc>().add(const OperationEventDefault());
              await BlocProvider.of<ResolveRedFlagBloc>(context).close();
            });
          }
        }
      },
      builder: (context, state) {
        if (state is ResolveRedFlagInitial) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Issue'),
              leading: BackButton(
                onPressed: () async {
                  context.read<FlaggedBloc>().add(const FlaggedEventRed());
                  await BlocProvider.of<ResolveRedFlagBloc>(context).close();
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  state.image != null
                      ? Image.memory(
                          state.image!,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/images/camera.png",
                          height: 250,
                          width: 250,
                        ),
                  Text('Date: ${state.flag.date}'),
                  Text('Latest Information: ${state.flag.comment}'),
                  TextField(
                    controller: _commentTextController,
                    decoration: const InputDecoration(hintText: 'Comment...'),
                    minLines: 3,
                    maxLines: 3,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        context.read<ResolveRedFlagBloc>().add(
                            ResolveRedFlagEventResolve(
                                newComment: _commentTextController.text));
                      },
                      child: const Text('Resolve')),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
