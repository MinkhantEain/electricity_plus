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
