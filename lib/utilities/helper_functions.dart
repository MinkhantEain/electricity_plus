

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
  return (num.parse(DateTime.now().toString().substring(0, 4)) - 1).toString() +
      DateTime.now().toString().substring(4, 7);
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

