import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/cloud/cloud_storage_constants.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/views/operations/management/app_user/add_new_user/bloc/add_new_user_bloc.dart';
import 'package:electricity_plus/views/operations/management/app_user/bloc/app_user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewUserView extends StatefulWidget {
  const AddNewUserView({super.key});

  @override
  State<AddNewUserView> createState() => _AddNewUserViewState();
}

class _AddNewUserViewState extends State<AddNewUserView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _passwordRetry;
  late final TextEditingController _name;
  String _userType = undecidedType;
  final userTypeList = List<String>.of([
    undecidedType,
    cashierType,
    meterReaderType,
    managerType,
    directorType,
    adminType
  ]);

  @override
  void initState() {
    _email = TextEditingController();
    _name = TextEditingController();
    _password = TextEditingController();
    _passwordRetry = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _passwordRetry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddNewUserBloc, AddNewUserState>(
      listener: (context, state) async {
        if (state is AddNewUserLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is AddNewUserStateEmptyEmailError) {
            await showErrorDialog(context, 'Email cannot be empty');
          } else if (state is AddNewUserStateEmptyNameError) {
            await showErrorDialog(context, 'Name cannot be empty');
          } else if (state is AddNewUserStateEmailAlreadyInUseError) {
            await showErrorDialog(context, 'Email Already in use.');
          } else if (state is AddNewUserStateEmptyPasswordError) {
            await showErrorDialog(context, 'Password cannot be empty');
          } else if (state is AddNewUserStateEmptyPasswordReEntryError) {
            await showErrorDialog(context, 'Password retry cannot be empty');
          } else if (state is AddNewUserStateInvalidEmailError) {
            await showErrorDialog(context, 'Invalid Email');
          } else if (state is AddNewUserStatePasswordUnmatchError) {
            await showErrorDialog(
                context, 'The two password fields does not match');
          } else if (state is AddNewUserStateUndecidedTypeError) {
            await showErrorDialog(context, 'User type cannot be undecided');
          } else if (state is AddNewUserStateWeakPasswordError) {
            await showErrorDialog(
                context, 'Password is weak. Use a stronger password');
          } else if (state is AddNewUserStateGenericAuthError) {
            await showErrorDialog(context, 'Unaccounted Authentication error');
          } else if (state is AddNewUserStateError) {
            await showErrorDialog(context, 'Unexpected Staff creation error');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () async {
              context.read<AppUserBloc>().add(const AppUserEventAppUser());
              await BlocProvider.of<AddNewUserBloc>(context).close();
            },
          ),
          title: const Text('Add New User'),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            children: [
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _email,
                decoration: const InputDecoration(hintText: 'Email...'),
              ),
              TextField(
                controller: _name,
                decoration: const InputDecoration(hintText: 'Name...'),
              ),
              TextField(
                enableSuggestions: false,
                obscureText: true,
                controller: _password,
                decoration: const InputDecoration(hintText: 'Password...'),
              ),
              TextField(
                enableSuggestions: false,
                obscureText: true,
                controller: _passwordRetry,
                decoration:
                    const InputDecoration(hintText: 'Re-Enter Password...'),
              ),
              DropdownButton(
                value: _userType,
                items: userTypeList
                    .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      _userType = value;
                    }
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AddNewUserBloc>().add(AddNewUserEventSubmit(
                        email: _email.text.trim(),
                        name: _name.text.trim(),
                        password: _password.text.trim(),
                        passwordReEntry: _passwordRetry.text.trim(),
                        userType: _userType,
                      ));
                },
                child: const Text('Submit'),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
