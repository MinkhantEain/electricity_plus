import 'package:electricity_plus/enums/menu_action.dart';
import 'package:electricity_plus/services/auth/bloc/auth_bloc.dart';
import 'package:electricity_plus/services/auth/bloc/auth_event.dart';
import 'package:electricity_plus/services/cloud/operation/operation_bloc.dart';
import 'package:electricity_plus/services/cloud/operation/operation_event.dart';
import 'package:electricity_plus/utilities/dialogs/home_page_dialog.dart';
import 'package:electricity_plus/utilities/dialogs/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget CustomButton({
  required String title,
  required IconData icon,
  required VoidCallback onClick,
}) {
  return SizedBox(
    width: 200,
    child: ElevatedButton(
        onPressed: onClick,
        child: Row(
          children: [Icon(icon), const SizedBox(width: 20), Text(title)],
        )),
  );
}

// Container HomePageButton(
//     {
//     required IconData icon,
//     required String text,
//     required VoidCallback onPressed}) {
//   return Container(
//     padding: const EdgeInsets.all(30.0),
//     child: SizedBox(
//       width: double.infinity,
//       height: 60,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         child:  Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             const SizedBox(
//               width: 10,
//             ),
//             Icon(
//               icon,
//               color: Colors.black54,
//               size: 40,
//             ),
//             const SizedBox(
//               width: 10,
//             ),
//             Text(
//               text,
//               style: const TextStyle(fontSize: 20),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
Container HomePageButton(
    {
    required IconData icon,
    required String text,
    required VoidCallback onPressed}) {
  return Container(
    padding: const EdgeInsets.all(10.0),
    child: SizedBox(
      child: ElevatedButton(
        onPressed: onPressed,
        child:  Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              // width: 10,
            ),
            Icon(
              icon,
              color: Colors.black54,
              // size: 40,
            ),
            const SizedBox(
              // width: 10,
            ),
            Container(
              alignment: Alignment.center,
              child:Text(
              text,
              textAlign: TextAlign.center,
              // style: const TextStyle(fontSize: 20),
            )),
          ],
        ),
      ),
    ),
  );
}

PopupMenuButton<MenuAction> AppBarMenu(BuildContext context) {
    return PopupMenuButton<MenuAction>(
                onSelected: (value) async {
                  switch (value) {
                    case MenuAction.logout:
                      final shouldLogout = await showLogOutDialog(context);
                      if (shouldLogout) {
                        // ignore: use_build_context_synchronously
                        context.read<AuthBloc>().add(const AuthEventLogOut());
                      }
                      break;
                    case MenuAction.home:
                      final shouldGoHome = await showHomePageDialog(context);
                      if (shouldGoHome) {
                        // ignore: use_build_context_synchronously
                        context
                            .read<OperationBloc>()
                            .add(const OperationEventDefault());
                      }
                      break;
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: MenuAction.home,
                      child: Row( children: [
                        Icon(Icons.home),
                        SizedBox(width: 5,),
                        Text('Home')
                      ]),
                    ),
                    PopupMenuItem(
                      value: MenuAction.logout,
                      child: Row(
                        children: [Icon(Icons.logout_sharp),
                        SizedBox(width: 5,),
                          Text("Logout"),
                        ],
                      ),
                    ),
                  ];
                },
              );
  }