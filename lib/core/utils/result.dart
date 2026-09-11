import 'package:equatable/equatable.dart';
import '../errors/failure.dart';

/// A functional Result type that encapsulates either a successful value of type [T]
/// or a domain [Failure].
sealed class Result<T> extends Equatable {
  const Result();

  /// Creates a successful result holding [value].
  const factory Result.ok(T value) = Ok<T>;

  /// Creates an error result holding [failure].
  const factory Result.err(Failure failure) = Err<T>;

  /// Whether the result is a success.
  bool get isOk => this is Ok<T>;

  /// Whether the result is a failure.
  bool get isErr => this is Err<T>;

  /// Extract value or return null.
  T? get valueOrNull => switch (this) {
        Ok(value: final v) => v,
        Err() => null,
      };

  /// Extract failure or return null.
  Failure? get failureOrNull => switch (this) {
        Ok() => null,
        Err(failure: final f) => f,
      };

  /// Match on success or failure.
  R fold<R>({
    required R Function(T value) onOk,
    required R Function(Failure failure) onErr,
  }) {
    return switch (this) {
      Ok(value: final v) => onOk(v),
      Err(failure: final f) => onErr(f),
    };
  }

  /// Transform the success value with [mapper].
  Result<R> map<R>(R Function(T value) mapper) {
    return switch (this) {
      Ok(value: final v) => Result.ok(mapper(v)),
      Err(failure: final f) => Result.err(f),
    };
  }

  /// Flat-map the success value with [mapper].
  Result<R> flatMap<R>(Result<R> Function(T value) mapper) {
    return switch (this) {
      Ok(value: final v) => mapper(v),
      Err(failure: final f) => Result.err(f),
    };
  }
}

final class Ok<T> extends Result<T> {
  final T value;

  const Ok(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Ok($value)';
}

final class Err<T> extends Result<T> {
  final Failure failure;

  const Err(this.failure);

  @override
  List<Object?> get props => [failure];

  @override
  String toString() => 'Err($failure)';
}
