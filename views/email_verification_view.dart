
import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Email Verification"),),
      body: Column(
        children: [
          const Text("We have sent a verification email."),
          const Text("If you have not received the email, press the button below."),
          ElevatedButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
              },
              child: const Text("Re-send email verification")),
          ElevatedButton(
              onPressed: () async {
                
              },
              child: const Text("Log in"))
        ],
      ),
    );
  }
}