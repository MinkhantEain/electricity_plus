import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/town_page_dialogs.dart';
import 'package:electricity_plus/views/operations/town_selection/bloc/town_selection_bloc.dart';
import 'package:electricity_plus/views/operations/town_selection/bloc/town_selection_exception.dart';
import 'package:electricity_plus/views/operations/town_selection/town_selection_view.dart';
import 'dart:developer' as dev show log;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TownSelectionFrame extends StatefulWidget {
  const TownSelectionFrame({super.key});

  @override
  State<TownSelectionFrame> createState() => _TownSelectionFrameState();
}

class _TownSelectionFrameState extends State<TownSelectionFrame> {
  late final TextEditingController _newTownTextController;
  late final TextEditingController _passwordTextController;

  @override
  void initState() {
    _newTownTextController = TextEditingController();
    _passwordTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _newTownTextController.dispose();
    _passwordTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TownSelectionBloc, TownSelectionState>(
      listener: (context, state) async {
        if (state is TownSelectionError) {
          LoadingScreen().hide();
          if (state.exception is InvalidPasswordException) {
            await showErrorDialog(context, state.message);
          }
        } else if (state is TownSelectionLoading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingMessage ?? 'Please wait a while...');
        } else if (state is TownSelectionLoaded) {
          LoadingScreen().hide();
        } else if (state is NewTownSelected) {
          LoadingScreen().hide();
          await showTownSelected(context, state.newTownName);
        } else if (state is TownSelectionStateDeleted) {
          LoadingScreen().hide();
          await showTownDelete(context, state.townName);
        } else if (state is TownSelectionStateTownAdded) {
          LoadingScreen().hide();
          await showTownAdded(context, state.townName);
        }
      },
      builder: (context, state) {
        dev.log(state.toString());
        if (state is TownSelectionInitialised) {
          final towns = state.towns;
          return TownSelectionView(towns: towns);
        } else {
          return const TownSelectionView(towns: []);
        }
      },
    );
  }
}
