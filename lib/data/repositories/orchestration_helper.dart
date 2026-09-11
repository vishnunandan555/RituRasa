import '../../core/errors/failure.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/result.dart';

/// Helper utility implementing Cache-First and Offline-First synchronization semantics.
class OrchestrationHelper {
  final INetworkInfo networkInfo;

  const OrchestrationHelper(this.networkInfo);

  /// Executes cache-first retrieval:
  /// 1. Tries local reader.
  /// 2. If valid data exists, returns it.
  /// 3. If local data is empty/null, attempts remote fetch if network is available.
  /// 4. Writes fetched data into local cache.
  /// 5. If network is offline and local data is missing, returns [OfflineDataUnavailableFailure].
  Future<Result<T>> executeCacheFirst<T>({
    required Future<Result<T?>> Function() readLocal,
    required Future<Result<T>> Function() fetchRemote,
    required Future<void> Function(T remoteData) writeLocal,
    bool Function(T? localData)? isLocalDataSufficient,
  }) async {
    final localResult = await readLocal();
    if (localResult.isOk && localResult.valueOrNull != null) {
      final isSufficient = isLocalDataSufficient?.call(localResult.valueOrNull) ?? true;
      if (isSufficient) {
        return Result.ok(localResult.valueOrNull as T);
      }
    }

    final isOnline = await networkInfo.isConnected;
    if (!isOnline) {
      if (localResult.isOk && localResult.valueOrNull != null) {
        return Result.ok(localResult.valueOrNull as T);
      }
      return const Result.err(OfflineDataUnavailableFailure());
    }

    // Connected: Fetch from remote API
    final remoteResult = await fetchRemote();
    if (remoteResult.isOk) {
      final remoteData = remoteResult.valueOrNull as T;
      try {
        await writeLocal(remoteData);
      } catch (_) {
        // Cache write failures should not abort successful remote reads
      }
      return Result.ok(remoteData);
    }

    // If remote fetch failed but some stale local data exists, return it as fallback
    if (localResult.isOk && localResult.valueOrNull != null) {
      return Result.ok(localResult.valueOrNull as T);
    }

    return Result.err(remoteResult.failureOrNull!);
  }
}
