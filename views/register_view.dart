import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/utilities/dialogs/auth_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electricity_plus/services/auth/auth_exception.dart';
import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/auth/bloc/auth_state.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'dart:developer' as dev show log;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _name;
  late final TextEditingController _password;
  late final TextEditingController _passwordReEntry;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _passwordReEntry = TextEditingController();
    _name = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordReEntry.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          dev.log(state.exception.toString());
          if (state.isLoading) {
            LoadingScreen().show(context: context, text: 'Loading...');
          } else {
            LoadingScreen().hide();
          }
          if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, "Email already in use");
          } else if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, "Weak Password");
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, "Invalid Email");
          } else if (state.exception
              is UnidenticalPasswordEntriesAuthException) {
            await showErrorDialog(context,
                "The two password entries are not the same, try again.");
          } else if (state.exception
              is UnidenticalPasswordEntriesAuthException) {
            await showPasswordReEntryErrorDialogs(context);
          } else if (state.exception is EmptyNameInputException) {
            await showErrorDialog(context, 'Cannot have empty name input');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, "Failed to register");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _name,
                enableSuggestions: false,
                keyboardType: TextInputType.name,
                autofocus: true,
                decoration: const InputDecoration(hintText: "Your Name here"),
              ),
              TextField(
                controller: _email,
                enableSuggestions: false,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration:
                    const InputDecoration(hintText: "Enter your email here"),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration:
                    const InputDecoration(hintText: "Enter your password here"),
              ),
              TextField(
                controller: _passwordReEntry,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                    hintText: "ReEnter your password here"),
              ),
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        final passwordReEntry = _passwordReEntry.text;
                        final name = _name.text;
                        context.read<AuthBloc>().add(AuthEventRegister(
                            email, password, passwordReEntry, name));
                      },
                      child: const Text('Register'),
                    ),
                    TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(const AuthEventLogOut());
                        },
                        child: const Text('Already registered?')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
