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
