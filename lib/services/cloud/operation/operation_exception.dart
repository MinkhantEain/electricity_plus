class OperationException implements Exception {
  const OperationException();
}

class InvalidSearchInputOperationException extends OperationException {}

class UnableToParseException extends OperationException {}

class EmptyTextInputException extends OperationException {}

class InvalidNewReadingException extends OperationException {}