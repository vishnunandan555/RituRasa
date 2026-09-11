import '../../core/utils/result.dart';
import '../../domain/models/cycle.dart';
import '../../domain/repositories/i_cycle_repository.dart';
import '../local/dao/cycle_dao.dart';

class CycleRepositoryImpl implements ICycleRepository {
  final CycleDao cycleDao;

  const CycleRepositoryImpl(this.cycleDao);

  @override
  Future<Result<List<CycleRecord>>> getCycleLogs() async {
    final result = await cycleDao.getCycleLogs();
    return result.map((rows) {
      return rows.map(_fromMap).toList();
    });
  }

  @override
  Future<Result<CycleRecord?>> getLatestCycleLog() async {
    final result = await cycleDao.getLatestCycleLog();
    return result.map((row) {
      if (row == null) return null;
      return _fromMap(row);
    });
  }

  @override
  Future<Result<void>> saveCycleLog(CycleRecord log) async {
    return await cycleDao.insertCycleLog({
      'id': log.id,
      'period_start': log.periodStart.toIso8601String().substring(0, 10),
      'period_end': log.periodEnd?.toIso8601String().substring(0, 10),
      'cycle_length': log.cycleLength,
      'created_at': log.createdAt.toIso8601String(),
      'updated_at': log.updatedAt.toIso8601String(),
    });
  }

  @override
  Future<Result<void>> deleteCycleLog(String id) async {
    return await cycleDao.deleteCycleLog(id);
  }

  CycleRecord _fromMap(Map<String, dynamic> map) {
    return CycleRecord(
      id: map['id'] as String,
      periodStart: DateTime.parse(map['period_start'] as String),
      periodEnd: map['period_end'] != null ? DateTime.tryParse(map['period_end'] as String) : null,
      cycleLength: (map['cycle_length'] as num?)?.toInt() ?? 28,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
