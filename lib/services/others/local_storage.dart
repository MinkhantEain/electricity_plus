import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppDocumentData {
  static Future<String> getTownName() async {
    final dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/townName.txt');
    final lines = await file.readAsLines();
    if (lines.isEmpty) {
      return '';
    } else {
      return lines.first;
    }
  }

  static Future<void> storeTownName(String townName) async {
    final dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/townName.txt');
    file.writeAsString(townName);
  }

  
}