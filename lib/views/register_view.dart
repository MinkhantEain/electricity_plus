import 'package:electricity_plus/app_images.dart';
import 'package:electricity_plus/services/auth/auth_exception.dart';
import 'package:electricity_plus/services/auth/auth_service.dart';
import 'package:electricity_plus/utilities/show_error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:electricity_plus/utilities/generic_diaglog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _HomePageState();
}

class _HomePageState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final Image _electricImage;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _electricImage = Image.asset(AppImages.electric);
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
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _electricImage,
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                hintText: "Email",
              ),
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(
                hintText: "Password",
              ),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
            ElevatedButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  AuthService.firebase().createUser(
                    email: email,
                    password: password,
                  );
                  if (context.mounted) {
                    await showGenericDialog(context, 'Registered!',
                        "Please verify your email before logging in");
                    await AuthService.firebase().sendEmailVerification();
                    await AuthService.firebase().logout();
                  }
                } on WeakPasswordAuthException {
                  await showErrorDialog(context, 'weak password');
                } on EmailAlreadyInUseAuthException {
                  await showErrorDialog(context, 'email already in use');
                } on InvalidEmailAuthException {
                  await showErrorDialog(context, 'invalid email');
                } on GenericAuthException {
                  await showErrorDialog(context, "Registeration Error");
                }
              },
              child: const Text("Register"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Back"),
            )
          ],
        ),
      ),
    );
  }
}
