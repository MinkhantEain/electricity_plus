import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/views/operations/management/bloc/admin_bloc.dart';
import 'package:electricity_plus/views/operations/management/town_selection/bloc/town_selection_bloc.dart';
import 'package:electricity_plus/views/operations/management/town_selection/town_selection_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TownSelectionView extends StatefulWidget {
  const TownSelectionView({super.key});

  @override
  State<TownSelectionView> createState() => _TownSelectionViewState();
}

class _TownSelectionViewState extends State<TownSelectionView> {
  late final TextEditingController _newTownTextController;

  @override
  void initState() {
    _newTownTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _newTownTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TownSelectionBloc, TownSelectionState>(
      listener: (context, state) async {
        if (state is TownSelectionLoading) {
          LoadingScreen().show(
              context: context, text: state.loadingMessage ?? 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is NewTownSelected) {
            await showTownSelected(context, state.newTownName);
          } else if (state is TownSelectionStateDeleted) {
            LoadingScreen().hide();
            await showTownDelete(context, state.townName);
          } else if (state is TownSelectionStateTownAdded) {
            LoadingScreen().hide();
            await showTownAdded(context, state.townName);
          } else if (state is TownSelectionEmptyTownNameInput) {
            await showEmptyTownNameInput(context);
          } else if (state is TownSelectionStateDeleteSelected) {
            await showTownDeleteConfirmation(context, state.townName);
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                context
                    .read<AdminBloc>()
                    .add(const AdminEventAdminView());
              },
            ),
            title: const Text('Town Selection'),
          ),
          body: Column(
            children: [
              TextField(
                decoration: const InputDecoration(hintText: 'New Town'),
                controller: _newTownTextController,
              ),
              ElevatedButton(
                  onPressed: () {
                    context.read<TownSelectionBloc>().add(TownSelectionAdd(
                          townName: _newTownTextController.text,
                        ));
                  },
                  style: const ButtonStyle(
                      fixedSize: MaterialStatePropertyAll(Size.fromWidth(100))),
                  child: const Text(
                    'Add',
                    style: TextStyle(fontSize: 20),
                  )),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.towns.length,
                  itemBuilder: (context, index) {
                    final town = state.towns.elementAt(index).toString();
                    return ListTile(
                      onTap: () async {
                        context
                            .read<TownSelectionBloc>()
                            .add(TownSelectionSelected(
                              townName: town,
                            ));
                      },
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(town),
                          IconButton(
                              onPressed: () {
                                context
                                    .read<TownSelectionBloc>()
                                    .add(TownSelectionDeleteSelect(townName: town));
                              },
                              icon: const Icon(Icons.delete_outline_outlined)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
