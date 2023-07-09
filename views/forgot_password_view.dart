
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/auth/bloc/auth_state.dart';
import 'package:electricity_plus/utilities/dialogs/error_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/password_reset_email_send_dialog.dart';

class ForgotPassowrdView extends StatefulWidget {
  const ForgotPassowrdView({super.key});

  @override
  State<ForgotPassowrdView> createState() => _ForgotPassowrdViewState();
}

class _ForgotPassowrdViewState extends State<ForgotPassowrdView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            // ignore: use_build_context_synchronously
            await showErrorDialog(context,
                'We could not process your request Please make sure you are a registered user.');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Forgot Password"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(6.8),
          child: Column(
            children: [
              const Text(
                  'If you forget your password, simply enter your email and we will send you a password reset email'),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                controller: _controller,
                decoration:
                    const InputDecoration(hintText: 'Your email address here'),
              ),
              TextButton(
                onPressed: () async {
                  final email = _controller.text;
                  context.read<AuthBloc>().add(AuthEventForgotPassword(email: email, townList: await AppDocumentData.getTownList()));
                },
                child: const Text("Send me passowrd reset link"),
              ),
              TextButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(AuthEventLogOut(townList: await AppDocumentData.getTownList()));
                },
                child: const Text("Back to login page"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
