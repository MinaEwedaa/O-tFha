import 'package:equatable/equatable.dart';

/// Base class for all failures in the app
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  
  const Failure(this.message, {this.code});
  
  @override
  List<Object?> get props => [message, code];
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

/// Storage failure
class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.code});
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}



