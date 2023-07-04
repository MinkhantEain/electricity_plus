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

class UnAuthorisedPersonException extends OperationException {}

class InvalidFileTypeException extends OperationException {}

class InvalidTokenException extends OperationException {}

class PrinterNotConnectedException extends OperationException {}