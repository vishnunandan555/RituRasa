import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/dependency_providers.dart';
import '../../core/utils/result.dart';
import '../../domain/models/intake_entry.dart';
import '../../domain/models/nutrient_totals.dart';
import '../../domain/repositories/i_intake_repository.dart';
import '../../domain/services/nutrition_progress_service.dart';

class IntakeState {
  final String date;
  final List<IntakeEntry> entries;
  final DailyProgressSummary? progressSummary;
  final bool isLoading;
  final String? errorMessage;

  const IntakeState({
    required this.date,
    this.entries = const [],
    this.progressSummary,
    this.isLoading = false,
    this.errorMessage,
  });

  IntakeState copyWith({
    String? date,
    List<IntakeEntry>? entries,
    DailyProgressSummary? progressSummary,
    bool? isLoading,
    String? errorMessage,
  }) {
    return IntakeState(
      date: date ?? this.date,
      entries: entries ?? this.entries,
      progressSummary: progressSummary ?? this.progressSummary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class IntakeNotifier extends Notifier<IntakeState> {
  late final IIntakeRepository _intakeRepository;
  late final NutritionProgressService _progressService;

  @override
  IntakeState build() {
    _progressService = ref.watch(nutritionProgressServiceProvider);
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    ref.watch(intakeRepositoryProvider).whenData((repo) {
      _intakeRepository = repo;
      loadIntakesForDate(todayStr);
    });
    return IntakeState(date: todayStr);
  }

  Future<void> loadIntakesForDate(String date) async {
    state = state.copyWith(date: date, isLoading: true, errorMessage: null);
    final res = await _intakeRepository.getIntakesForDate(date);
    res.fold(
      onOk: (entries) {
        final progress = _progressService.calculateDailyProgress(
          date: date,
          intakes: entries,
        );
        state = state.copyWith(
          entries: entries,
          progressSummary: progress,
          isLoading: false,
        );
      },
      onErr: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
      },
    );
  }

  Future<Result<void>> logMeal({
    String? foodId,
    String? recipeId,
    required String name,
    required double quantity,
    required String unit,
    required MealType mealType,
    required Map<String, double> nutrients,
  }) async {
    final now = DateTime.now();
    final entry = IntakeEntry(
      id: 'intake_${now.millisecondsSinceEpoch}',
      date: state.date,
      foodId: foodId,
      recipeId: recipeId,
      name: name,
      quantity: quantity,
      unit: unit,
      mealType: mealType,
      nutrients: nutrients,
      loggedAt: now,
    );

    final res = await _intakeRepository.logIntake(entry);
    if (res.isOk) {
      await loadIntakesForDate(state.date);
      if (state.progressSummary != null) {
        await _intakeRepository.saveDailyNutrientTotals(state.progressSummary!.totals);
      }
    }
    return res;
  }

  Future<Result<void>> removeIntake(String id) async {
    final res = await _intakeRepository.deleteIntake(id);
    if (res.isOk) {
      await loadIntakesForDate(state.date);
    }
    return res;
  }
}

final intakeNotifierProvider = NotifierProvider<IntakeNotifier, IntakeState>(IntakeNotifier.new);
