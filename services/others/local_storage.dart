

import 'dart:io';

import 'package:electricity_plus/services/others/town.dart';
import 'package:path_provider/path_provider.dart';

class AppDocumentData {
  static Future<String> getTownName() async {
    final dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/townName.txt');
    try {
      final lines = await file.readAsLines();
      return lines.first;
    } on Exception {
      return 'Town Not Chosen';
    }
  }

  static Future<Iterable<Town>> getTownList() async {
    final dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/townList.txt');
    try {
      final lines = await file.readAsLines();
      Iterable<Town> towns = lines.first.split(',').map((e) => Town(townName: e));
      return towns;
    } on Exception {
      return [];
    }
  }

  static Future<num> townCount() async {
    final townList = await getTownList();
    return townList.length;
  }

  static Future<void> storeTownList(Iterable<Town> towns) async {
    List<String> strTowns = [];
    for (var town in towns) {
      strTowns.add(town.toString());
    }
    final dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/townList.txt');
    await file.writeAsString(strTowns.join(','));
  }

  static Future<void> storeTownName(String townName) async {
    final dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/townName.txt');
    await file.writeAsString(townName);
  }

  
}