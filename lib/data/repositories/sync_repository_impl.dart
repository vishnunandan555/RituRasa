import '../../core/config/app_config.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/i_sync_repository.dart';
import '../local/dao/sync_metadata_dao.dart';
import '../remote/api/simple_nutri_api_service.dart';

class SyncRepositoryImpl implements ISyncRepository {
  final SyncMetadataDao syncMetadataDao;
  final SimpleNutriApiService? apiService;

  const SyncRepositoryImpl({
    required this.syncMetadataDao,
    this.apiService,
  });

  @override
  Future<Result<String?>> getLocalDatasetVersion() async {
    final res = await syncMetadataDao.getMetadata(AppConfig.syncKeyDatasetVersion);
    if (res.isOk && res.valueOrNull != null) {
      return res;
    }
    return const Result.ok(AppConfig.currentDatasetVersion);
  }

  @override
  Future<Result<void>> setLocalDatasetVersion(String version) async {
    return await syncMetadataDao.setMetadata(AppConfig.syncKeyDatasetVersion, version);
  }

  @override
  Future<Result<String?>> getRemoteDatasetVersion() async {
    if (apiService == null) {
      return const Result.ok(null);
    }
    final health = await apiService!.fetchHealth();
    return health.map((h) => h.datasetVersion ?? h.version);
  }
}
