/// Application configuration and environment constants for RituRasa.
class AppConfig {
  AppConfig._();

  /// SimpleNutriAPI remote base URL.
  /// Defaults to localhost for development/local testing.
  /// In production, can be overridden via dart-define or runtime settings.
  static const String defaultApiBaseUrl = 'http://127.0.0.1:8000';
  static const String apiVersionPath = '/api/v1';

  /// Connect and receive timeouts for HTTP client.
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 8);
  static const int maxRetryAttempts = 2;

  /// Database asset and file paths.
  static const String referenceDbAssetName = 'assets/database/nutrition_reference.db';
  static const String referenceDbFileName = 'nutrition_reference.db';
  static const String userDbFileName = 'riturasa_user.db';

  /// Database versions.
  static const int userDatabaseVersion = 1;
  static const String currentDatasetVersion = '1.0.0';

  /// Metadata keys for sync.
  static const String syncKeyDatasetVersion = 'reference_dataset_version';
  static const String syncKeyLastCheckedAt = 'reference_last_checked_at';
  static const String syncKeyLastSynchronizedAt = 'reference_last_synchronized_at';
}
