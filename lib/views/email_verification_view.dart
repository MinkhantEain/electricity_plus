import 'package:electricity_plus/constants/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
              },
              child: const Text("Re-send email verification")),
          ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).pushNamedAndRemoveUntil(loginView, (route) => false);
              },
              child: const Text("Log in"))
        ],
      ),
    );
  }
}