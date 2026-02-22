import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error occurred']);
}

class GenericFailure extends Failure {
  const GenericFailure([super.message = 'An error occurred']);
}
