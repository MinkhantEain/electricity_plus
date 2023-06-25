import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_exception.dart';
import 'package:electricity_plus/services/cloud/operation/operation_state.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'dart:developer' as dev show log;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseTownView extends StatefulWidget {
  const ChooseTownView({super.key});

  @override
  State<ChooseTownView> createState() => _ChooseTownViewState();
}

class _ChooseTownViewState extends State<ChooseTownView> {
  late final TextEditingController _textEditingController;
  late final TextEditingController _passwordTextController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _passwordTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperationBloc, OperationState>(
      listener: (context, state) async {
        if (state is OperationStateChooseTown) {
          if (state.exception is InvalidTokenException) {
            await showErrorDialog(context, 'Error: Invalid Admin Password.');
          }
        }
      },
      builder: (context, state) {
        if (state is OperationStateChooseTown) {
          final towns = state.towns;
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  context
                      .read<OperationBloc>()
                      .add(const OperationEventAdminView());
                },
              ),
              title: const Text('Choose Town'),
            ),
            body: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(hintText: 'New Town'),
                  controller: _textEditingController,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Admin Password'),
                  controller: _passwordTextController,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                ElevatedButton(
                    onPressed: () {
                      context.read<OperationBloc>().add(
                          OperationEventAddNewTown(
                              townName: _textEditingController.text,
                              token: _passwordTextController.text));
                    },
                    child: const Text('Add')),
                Expanded(
                  child: ListView.builder(
                    itemCount: towns.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          dev.log(await AppDocumentData.getTownName());
                          await AppDocumentData.storeTownName(
                              towns.elementAt(index).toString());
                          dev.log(await AppDocumentData.getTownName());
                        },
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(towns.elementAt(index).toString()),
                            IconButton(
                                onPressed: () {
                                  context.read<OperationBloc>().add(
                                      OperationEventDeleteTown(
                                          token: _passwordTextController.text,
                                          townName: towns
                                              .elementAt(index)
                                              .toString()));
                                },
                                icon:
                                    const Icon(Icons.delete_outline_outlined)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
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
