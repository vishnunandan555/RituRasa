import '../../../core/utils/result.dart';
import '../models/cycle.dart';

/// Repository interface for menstrual cycle logs and history.
abstract class ICycleRepository {
  Future<Result<List<CycleRecord>>> getCycleLogs();
  Future<Result<CycleRecord?>> getLatestCycleLog();
  Future<Result<void>> saveCycleLog(CycleRecord log);
  Future<Result<void>> deleteCycleLog(String id);
}
