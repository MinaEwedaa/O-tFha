/// Custom exception classes for better error handling
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  
  AppException(this.message, {this.code, this.details});
  
  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.details});
}

/// Authentication-related exceptions
class AuthException extends AppException {
  AuthException(super.message, {super.code, super.details});
}

/// Authorization-related exceptions
class PermissionException extends AppException {
  PermissionException(super.message, {super.code, super.details});
}

/// Data validation exceptions
class ValidationException extends AppException {
  ValidationException(super.message, {super.code, super.details});
}

/// Resource not found exceptions
class NotFoundException extends AppException {
  NotFoundException(super.message, {super.code, super.details});
}

/// Server error exceptions
class ServerException extends AppException {
  ServerException(super.message, {super.code, super.details});
}

/// Cache-related exceptions
class CacheException extends AppException {
  CacheException(super.message, {super.code, super.details});
}

/// File/Storage-related exceptions
class StorageException extends AppException {
  StorageException(super.message, {super.code, super.details});
}

/// Unknown or unhandled exceptions
class UnknownException extends AppException {
  UnknownException(super.message, {super.code, super.details});
}



