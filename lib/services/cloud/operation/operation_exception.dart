class OperationException implements Exception {
  const OperationException();
}

class InvalidSearchInputOperationException extends OperationException {}

class UnableToParseException extends OperationException {}

class InvalidMeterReadingException extends OperationException {}

class InvalidHorsePowerUnitException extends OperationException {}

class InvalidMeterMultiplierException extends OperationException {}

class EmptyTextInputException extends OperationException {}

class InvalidNewReadingException extends OperationException {}

class InvalidBookIdFormatException extends OperationException {}