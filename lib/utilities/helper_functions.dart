import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:electricity_plus/services/others/local_storage.dart';
import 'package:flutter/services.dart';

bool isNumeric(String? input) {
  if (input == null) {
    return false;
  } else {
    if (num.tryParse(input) == null) {
      return false;
    } else {
      return true;
    }
  }
}

String currentMonthYearDate() {
  return DateTime.now().toString().substring(0, 7);
}

String pastMonthYearDate() {
  return '${num.parse(DateTime.now().toString().substring(0, 4)) - 1}${DateTime.now().toString().substring(4, 7)}-01';
}

bool isBookIdFormat(String input) {
  final inputCodeUnit = input.codeUnits;
  if (!intIsBetween(inputCodeUnit[0], 65, 90)) {
    return false;
  }
  if (input[2] != '/' && input[5] != '/') {
    return false;
  }
  input = input.substring(1).replaceAll(RegExp(r'/'), '');
  for (int code in input.codeUnits) {
    if (!intIsBetween(code, 48, 57)) {
      return false;
    }
  }
  return true;
}

bool intIsBetween(int input, int startInclusive, int endInclusive) {
  return input >= startInclusive && input <= endInclusive;
}

bool isIntInput(String input) {
  if (input.isEmpty) {
    return false;
  }
  final codes = input.codeUnits;
  for (int code in codes) {
    if (!intIsBetween(code, 48, 57)) {
      return false;
    }
  }
  return true;
}

Future<List<LineText>> printBillHelper(Map<String, String?> details) async {
  final town = await AppDocumentData.getTownName();
  List<LineText> result = [];
  result.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '********************************',
      weight: 1,
      align: LineText.ALIGN_CENTER,
      linefeed: 1));
  result.add(LineText(
      type: LineText.TYPE_IMAGE,
      content: 'dfs',
      align: LineText.ALIGN_CENTER,
      linefeed: 1));
  result.add(LineText(
      type: LineText.TYPE_TEXT,
      content: town,
      weight: 1,
      align: LineText.ALIGN_CENTER,
      linefeed: 1));
  result.add(LineText(linefeed: 1));
  for (var key in details.keys) {
    if (details[key] == null) {
      continue;
    } else {
      result.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '$key: ${details[key]}',
          weight: 1,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
    }
  }
  result.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '********************************',
      weight: 1,
      align: LineText.ALIGN_CENTER,
      linefeed: 1));
  return result;
}
