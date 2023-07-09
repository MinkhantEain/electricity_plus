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
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.read<AppUserBloc>().add(const AppUserEventAppUser());
            BlocProvider.of<AddNewUserBloc>(context).close();
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
            ElevatedButton(
              onPressed: () {},
              child: const Text('Submit'),
            ),
          ],
        )),
      ),
    );
  }
}
