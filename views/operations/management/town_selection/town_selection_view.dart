import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/services/others/town.dart';
import 'package:electricity_plus/views/operations/management/town_selection/bloc/town_selection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TownSelectionView extends StatefulWidget {
  final Iterable<Town> towns;
  const TownSelectionView({super.key, required this.towns});

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
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.read<OperationBloc>().add(const OperationEventAdminView());
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
                    townName: _newTownTextController.text,));
              },
              style: const ButtonStyle(fixedSize: MaterialStatePropertyAll(Size.fromWidth(100))),
              child: const Text('Add',style: TextStyle(fontSize: 20),)),
              const Divider(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.towns.length,
              itemBuilder: (context, index) {
                final town = widget.towns.elementAt(index).toString();
                return ListTile(
                  onTap: () async {
                    context.read<TownSelectionBloc>().add(TownSelectionSelected(townName: town,));
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(town),
                      IconButton(
                          onPressed: () {
                            context.read<TownSelectionBloc>().add(
                                TownSelectionDelete(
                                    townName: town));
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
  }
}
