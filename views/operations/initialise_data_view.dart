import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InitialiseDataView extends StatefulWidget {
  const InitialiseDataView({super.key});

  @override
  State<InitialiseDataView> createState() => _InitialiseDataViewState();
}

class _InitialiseDataViewState extends State<InitialiseDataView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperationBloc, OperationState>(
      listener: (context, state) {
        if (state is OperationStateInitialiseData) {}
      },
      builder: (context, state) {
        if (state is OperationStateInitialiseData) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  context
                      .read<OperationBloc>()
                      .add(const OperationEventAdminView());
                },
              ),
              title: const Text("Initialise Data"),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'File Name: ${state.fileName}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Text('File bytes: ${state.fileBytes}'),
                Text('File extension: ${state.fileExtension}'),
                Text(
                  'File path: ${state.filePath}',
                  overflow: TextOverflow.ellipsis,
                ),
                Text('File size: ${state.fileSize}'),
                CustomButton(
                  title: 'Choose File',
                  icon: Icons.file_open,
                  onClick: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.any,
                      withData: false,
                      allowMultiple: false,
                    );
                    if (result != null) {
                      // ignore: use_build_context_synchronously
                      context.read<OperationBloc>().add(
                            OperationEventInitialiseData(
                                result: result.files.first, submit: false),
                          );
                    }
                  },
                ),
                ElevatedButton(
                    onPressed: () {
                      context.read<OperationBloc>().add(
                            OperationEventInitialiseDataSubmission(
                                result: state.platformFile),
                          );
                    },
                    child: const Text('Submit')),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
