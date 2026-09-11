import '../../core/utils/result.dart';
import '../repositories/i_sync_repository.dart';

/// Service managing nutritional reference dataset versioning and sync verification.
class SyncService {
  final ISyncRepository syncRepository;

  const SyncService(this.syncRepository);

  /// Check whether a newer reference dataset is available remotely.
  Future<Result<bool>> isUpdateAvailable() async {
    final localVerRes = await syncRepository.getLocalDatasetVersion();
    final remoteVerRes = await syncRepository.getRemoteDatasetVersion();

    if (remoteVerRes.isErr || remoteVerRes.valueOrNull == null) {
      return const Result.ok(false);
    }

    final localVer = localVerRes.valueOrNull ?? '1.0.0';
    final remoteVer = remoteVerRes.valueOrNull!;

    return Result.ok(localVer != remoteVer);
  }

  /// Mark dataset updated with the new version.
  Future<Result<void>> markUpdated(String newVersion) async {
    return await syncRepository.setLocalDatasetVersion(newVersion);
  }
}
