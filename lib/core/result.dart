import 'package:flutter_movies_module/core/error/failures.dart';

/// Custom Result type to replace dartz's Either
/// Success = Right, Failure = Left
abstract class Result<T> {
  const Result();

  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess);

  Result<R> map<R>(R Function(T) f);
  Result<R> flatMap<R>(Result<R> Function(T) f);

  T? getOrNull();
  Failure? getErrorOrNull();
}

class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) =>
      onSuccess(value);

  @override
  Result<R> map<R>(R Function(T) f) => Success(f(value));

  @override
  Result<R> flatMap<R>(Result<R> Function(T) f) => f(value);

  @override
  T? getOrNull() => value;

  @override
  Failure? getErrorOrNull() => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class Failure_<T> extends Result<T> {
  final Failure failure;

  const Failure_(this.failure);

  @override
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) =>
      onFailure(failure);

  @override
  Result<R> map<R>(R Function(T) f) => Failure_(failure);

  @override
  Result<R> flatMap<R>(Result<R> Function(T) f) => Failure_(failure);

  @override
  T? getOrNull() => null;

  @override
  Failure? getErrorOrNull() => failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure_ &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

// Convenience types for compatibility
typedef Either<L, R> = Result;

// Convenience constructors
Result<T> Right<T>(T value) => Success(value);
Result<T> Left<T>(Failure failure) => Failure_(failure);
