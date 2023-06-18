import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/auth/bloc/auth_state.dart';
import 'package:electricity_plus/services/auth/firebase_auth_provider.dart';
import 'package:electricity_plus/services/cloud/firebase_cloud_storage.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/views/forgot_password_view.dart';
import 'package:electricity_plus/views/login_view.dart';
import 'package:electricity_plus/views/operations/operation_page_views.dart';
import 'package:electricity_plus/views/register_view.dart';
import 'package:electricity_plus/views/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
      ),
      BlocProvider<OperationBloc>(
        create: (context) => OperationBloc(FirebaseCloudStorage()),
      ),
    ],
    child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        home: const HomePage()),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialise());

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'Plase wait a moment');
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const OperationPageViews();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPassowrdView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
