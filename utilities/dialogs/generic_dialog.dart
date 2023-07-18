import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: options.keys.map((optionTitle) {
          final value = options[optionTitle];
          return TextButton(onPressed: () {
            if (value != null) {
              Navigator.of(context).pop(value);
            } else {
              Navigator.of(context).pop();
            }
          }, child: Text(optionTitle));
        }).toList(),
      );
    },
  );
}


Future<T?> showGenericOptionDialog<T>({
  required BuildContext context,
  required String title,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        actionsAlignment: MainAxisAlignment.center,
        actions: options.keys.map((optionTitle) {
          final value = options[optionTitle];
          return TextButton(onPressed: () {
            if (value != null) {
              Navigator.of(context).pop(value);
            } else {
              Navigator.of(context).pop();
            }
          }, child: Text(optionTitle));
        }).toList(),
      );
    },
  );
}

Future<T?> showGenericInputEnquirerDialog<T>({
  required BuildContext context,
  required String title,
}) {
  final textController = TextEditingController();
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Meter Allowance',
            ),
          ),
          TextButton(onPressed: () {
            Navigator.of(context).pop(textController.text.trim());
          }, child: const Text('Enter')),
          TextButton(onPressed: () {
            Navigator.of(context).pop();
          }, child: const Text('Cancel')),
        ],
      );
    },
  );
}

