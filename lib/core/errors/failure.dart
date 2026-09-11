import 'package:equatable/equatable.dart';

/// Base class for all domain and data failures in RituRasa.
/// The UI and presentation controllers consume typed Failures rather than
/// raw network exceptions (DioException) or SQLite exceptions.
sealed class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic cause;

  const Failure({
    required this.message,
    this.code,
    this.cause,
  });

  @override
  List<Object?> get props => [message, code, cause];

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Network connectivity is unreachable or client is offline.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network connection unavailable. Operating in offline mode.',
    super.code = 'NETWORK_UNAVAILABLE',
    super.cause,
  });
}

/// SimpleNutriAPI request timed out (connect/receive).
class ApiTimeoutFailure extends Failure {
  const ApiTimeoutFailure({
    super.message = 'Remote API request timed out.',
    super.code = 'API_TIMEOUT',
    super.cause,
  });
}

/// Remote API returned an error response (4xx, 5xx) or invalid payload.
class ApiResponseFailure extends Failure {
  final int? statusCode;

  const ApiResponseFailure({
    required super.message,
    this.statusCode,
    super.code = 'API_ERROR',
    super.cause,
  });

  @override
  List<Object?> get props => [message, code, statusCode, cause];
}

/// SQLite database read/write or connection failure.
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code = 'DATABASE_ERROR',
    super.cause,
  });
}

/// Requested entity (food, recipe, cycle record, etc.) was not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code = 'NOT_FOUND',
    super.cause,
  });
}

/// Failure during cycle calculation due to invalid dates or corrupted state.
class CycleCalculationFailure extends Failure {
  const CycleCalculationFailure({
    required super.message,
    super.code = 'CYCLE_CALCULATION_ERROR',
    super.cause,
  });
}

/// Requested operation cannot proceed because data is missing locally while offline.
class OfflineDataUnavailableFailure extends Failure {
  const OfflineDataUnavailableFailure({
    super.message = 'Requested nutritional data is not available offline.',
    super.code = 'OFFLINE_DATA_UNAVAILABLE',
    super.cause,
  });
}

/// Reference dataset synchronization or migration failed.
class SyncFailure extends Failure {
  const SyncFailure({
    required super.message,
    super.code = 'SYNC_ERROR',
    super.cause,
  });
}

/// General validation or domain rule violation.
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.cause,
  });
}
