import 'package:electricity_plus/app_images.dart';
import 'package:electricity_plus/constants/routes.dart';
import 'package:electricity_plus/services/auth/auth_exception.dart';
import 'package:electricity_plus/services/auth/auth_service.dart';
import 'package:electricity_plus/utilities/show_error_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev show log;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        appBar: AppBar(title: const Text("Login")),
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
                    await AuthService.firebase().login(
                      email: email,
                      password: password,
                    );
                    final user = AuthService.firebase().currentUser;
                    if (user?.isEmailVerified ?? false) {
                      if (context.mounted) {
                        await Navigator.of(context).pushNamedAndRemoveUntil(
                          homePageView,
                          (route) => false,
                        );
                      }
                    } else {
                      if (context.mounted) {
                        await Navigator.of(context).pushNamedAndRemoveUntil(
                          emailVerificationView,
                          (route) => false,
                        );
                      }
                    }
                  } on UserNotFoundAuthException {
                    await showErrorDialog(context, "User not found");
                  } on WrongPasswordAuthException {
                    await showErrorDialog(context, "wrong password");
                  } on GenericAuthException {
                    await showErrorDialog(context, 'Authentication Error');
                  }
                },
                child: const Text("Login"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await Navigator.of(context).pushNamed(registerView);
                  } catch (e) {
                    await showErrorDialog(context, e.toString());
                  }
                },
                child: const Text("No account? Register"),
              ),
            ],
          ),
        ));
  }
}
