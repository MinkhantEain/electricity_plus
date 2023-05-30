import 'package:electricity_plus/constants/routes.dart';
import 'package:electricity_plus/views/email_verification_view.dart';
import 'package:electricity_plus/views/home_page_view.dart';
import 'package:electricity_plus/views/login_view.dart';
import 'package:electricity_plus/views/register_view.dart';
import 'package:electricity_plus/views/starting_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(primarySwatch: Colors.yellow),
    home: const StartingPage(),
    routes: {
      registerView: (context) => const RegisterView(),
      loginView: (context) => const LoginView(),
      emailVerificationView: (context) => const EmailVerificationView(),
      homePageView: (context) => const HomePageView(),
      startingPage: (context) => const StartingPage(),
    },
  ));
}
