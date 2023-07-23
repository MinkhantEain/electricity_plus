
import 'package:electricity_plus/utilities/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electricity_plus/services/auth/auth_exception.dart';
import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/auth/bloc/auth_state.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
                context, 'Cannot find user with the entered credentials');
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong Credentials');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, "Authentication Error");
          }
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedOut) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Login"),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _email,
                    enableSuggestions: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        hintText: "Enter your email here"),
                  ),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        hintText: "Enter your password here"),
                  ),
                  TownListDropDown(context, state.townList, state.town, state),
                
                  TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      context.read<AuthBloc>().add(AuthEventLogIn(
                          email: email,
                          password: password,
                          townList: state.townList));
                    },
                    child: const Text('Login'),
                  ),
                  TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              AuthEventShouldRegister(townList: state.townList),
                            );
                      },
                      child: const Text("Not registered yet?")),
                  TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              AuthEventForgotPassword(townList: state.townList),
                            );
                      },
                      child: const Text("I forgot my passoword")),
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
