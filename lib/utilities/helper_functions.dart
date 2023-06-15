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