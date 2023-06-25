import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppDocumentData {
  static Future<String> getTownName() async {
    final dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/townName.txt');
    try {
      final lines = await file.readAsLines();
      return lines.first;
    } on Exception catch(e) {
      return 'Town Not Chosen';
    }
  }

  static Future<void> storeTownName(String townName) async {
    final dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/townName.txt');
    file.writeAsString(townName);
  }

  
}