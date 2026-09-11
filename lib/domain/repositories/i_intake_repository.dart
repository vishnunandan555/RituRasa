import '../../../core/utils/result.dart';
import '../models/intake_entry.dart';
import '../models/nutrient_totals.dart';

/// Repository interface for food intake logging and aggregated nutrient totals.
abstract class IIntakeRepository {
  Future<Result<void>> logIntake(IntakeEntry entry);
  Future<Result<List<IntakeEntry>>> getIntakesForDate(String date);
  Future<Result<List<IntakeEntry>>> getDateRangeIntakes(String startDate, String endDate);
  Future<Result<void>> deleteIntake(String id);
  Future<Result<DailyNutrientTotals?>> getDailyNutrientTotals(String date);
  Future<Result<void>> saveDailyNutrientTotals(DailyNutrientTotals totals);
}
