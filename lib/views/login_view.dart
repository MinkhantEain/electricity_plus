import 'package:electricity_plus/app_images.dart';
import 'package:electricity_plus/firebase_options.dart';
import 'package:electricity_plus/constants/routes.dart';
import 'package:electricity_plus/utilities/show_error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return SingleChildScrollView(
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
                          final userCredential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          if (userCredential.user?.emailVerified ?? false) {
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  homePageView, (route) => false);
                            }
                          } else {
                            if (context.mounted) {
                              Navigator.of(context).pushNamed(emailVerificationView);
                            }
                          }
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            await showErrorDialog(context, "User not found");
                          } else if (e.code == 'wrong-password') {
                            await showErrorDialog(context, "wrong password");
                          } else {
                            await showErrorDialog(context, e.code);
                          }
                        } catch (e) {
                          await showErrorDialog(context, e.toString());
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
                      child: const Text("No account?"),
                    ),
                  ],
                ),
              );
            default:
              return const Text('Loading');
          }
        },
      ),
    );
  }
}
