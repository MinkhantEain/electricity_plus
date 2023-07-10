// import 'package:electricity_plus/services/others/local_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
// import 'package:electricity_plus/services/auth/bloc/auth_event.dart';

// class VerifyEmailView extends StatefulWidget {
//   const VerifyEmailView({super.key});

//   @override
//   State<VerifyEmailView> createState() => _VerifyEmailViewState();
// }

// class _VerifyEmailViewState extends State<VerifyEmailView> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Email Verification')),
//       body: Column(
//         children: [
//           const Text(
//               "We've sent you an email verification. Please click on the link sent to verify your account."),
//           const Text(
//               "If you haven't received a verifiation email yet, press the button below"),
//           TextButton(
//             onPressed: () async {
//               context
//                   .read<AuthBloc>()
//                   .add(AuthEventSendEmailVerification(townList: await AppDocumentData.getTownList()));
//             },
//             child: const Text("Send Email Verification"),
//           ),
//           TextButton(
//             onPressed: () async {
//               context
//                   .read<AuthBloc>()
//                   .add(AuthEventLogOut(townList: await AppDocumentData.getTownList()));
//             },
//             child: const Text("Restart"),
//           ),
//         ],
//       ),
//     );
//   }
// }
