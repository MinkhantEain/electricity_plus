class CloudStorageException implements Exception {
  const CloudStorageException();
}

//The CRUD Exceptions

//C
class CouldNotCreateException extends CloudStorageException {}

//R
class CouldNoteGetAllNotesException extends CloudStorageException {}

//U
class CouldNotUpdateNoteException extends CloudStorageException {}

//D
class CouldNotDeleteNoteException extends CloudStorageException {}


class CouldNotUpdateUnitException extends CloudStorageException {}

class CouldNotGetCustomerException extends CloudStorageException {}

class CouldNotGetPriceException extends CloudStorageException {}

class CouldNotSetPriceException extends CloudStorageException {}

class UnAuthorizedPriceSetException extends CloudStorageException {}


class CouldNotGetServiceChargeException extends CloudStorageException {}

class UnableToUploadImageException extends CloudStorageException {}

class UnableToUpdateException extends CloudStorageException {}

class CouldNotCreateCustomerException extends CloudStorageException {}

class CustomerAlreadyExistsException extends CloudStorageException {}

class CouldNotGetCustomerHistoryException extends CloudStorageException {}

class NoSuchDocumentException extends CloudStorageException {}

class CouldNotGetPasswordException extends CloudStorageException {}

class NonAdminUserException extends CloudStorageException {}

class CouldNotMakePaymentException extends CloudStorageException {}

class CouldNotFindReceiptDocException extends CloudStorageException {}

class InvalidTownNameException extends CloudStorageException {}