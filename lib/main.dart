import 'package:electricity_plus/firebase_options.dart';
import 'package:electricity_plus/constants/routes.dart';
import 'package:electricity_plus/views/email_verification_view.dart';
import 'package:electricity_plus/views/home_page_view.dart';
import 'package:electricity_plus/views/login_view.dart';
import 'package:electricity_plus/views/register_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(primarySwatch: Colors.yellow),
    home: const LoginView(),
    routes: {
      registerView: (context) => const RegisterView(),
      loginView: (context) => const LoginView(),
      emailVerificationView: (context) => const EmailVerificationView(),
      homePageView: (context) => const HomePageView(),
      home: (context) => const HomePage(),
    },
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user?.emailVerified ?? false) {
                return const HomePageView();
              } else {
                if (user == null) {
                  return const LoginView();
                } else {
                  return const EmailVerificationView();
                }
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

