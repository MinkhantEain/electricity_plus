import 'package:electricity_plus/services/others/local_storage.dart';
import 'dart:developer' as dev show log;
import 'package:flutter/material.dart';

class ChooseTownView extends StatefulWidget {
  const ChooseTownView({super.key});

  @override
  State<ChooseTownView> createState() => _ChooseTownViewState();
}

class _ChooseTownViewState extends State<ChooseTownView> {
  final townList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: townList.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () async {
              dev.log(await AppDocumentData.getTownName());
              await AppDocumentData.storeTownName(townList[index].toString());
              dev.log(await AppDocumentData.getTownName());
            },
            title: Text(townList[index].toString()),
          );
        },
      ),
    );
  }
}
