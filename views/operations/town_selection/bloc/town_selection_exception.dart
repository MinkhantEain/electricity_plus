class TownSelectionException implements Exception {
  const TownSelectionException();
}

class InvalidPasswordException extends TownSelectionException {
  const InvalidPasswordException();
}