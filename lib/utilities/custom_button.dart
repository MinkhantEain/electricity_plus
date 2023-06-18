import 'package:flutter/material.dart';

Widget CustomButton({
  required String title,
  required IconData icon,
  required VoidCallback onClick,
}) {
  return Container(
    width: 200,
    child: ElevatedButton(
        onPressed: onClick,
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 20),
            Text(title)
          ],
        )),
  );
}
