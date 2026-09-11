import '../../../core/utils/result.dart';

/// Repository interface for version tracking and reference dataset sync.
abstract class ISyncRepository {
  Future<Result<String?>> getLocalDatasetVersion();
  Future<Result<void>> setLocalDatasetVersion(String version);
  Future<Result<String?>> getRemoteDatasetVersion();
}
