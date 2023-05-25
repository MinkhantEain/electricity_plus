import 'dart:developer';

import 'package:electricity_plus/app_images.dart';
import 'package:electricity_plus/firebase_options.dart';
import 'package:electricity_plus/utilities/show_error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return SingleChildScrollView(
                child: SingleChildScrollView(
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
                                .createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            );
                            if (context.mounted) {
                              await showGenericDialog(context, 'Registered!',
                                  "Please verify your email before logging in");
                                  await FirebaseAuth.instance.currentUser?.sendEmailVerification();
                                  await FirebaseAuth.instance.signOut();
                            }
                          } on FirebaseAuthException catch (e) {
                            if (e.code == "weak-passowrd") {
                              await showErrorDialog(context, 'weak password');
                            } else if (e.code == 'email-already-in-use') {
                              await showErrorDialog(
                                  context, 'email already in use');
                            } else if (e.code == 'invalid-email') {
                              await showErrorDialog(context, 'invalid email');
                            } else {
                              await showErrorDialog(context, e.code);
                            }
                          } catch (e) {
                            await showErrorDialog(context, e.toString());
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
            default:
              return const Text('Loading');
          }
        },
      ),
    );
  }
}
