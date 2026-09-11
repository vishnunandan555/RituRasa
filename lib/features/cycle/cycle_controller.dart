import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/dependency_providers.dart';
import '../../core/utils/result.dart';
import '../../domain/models/cycle.dart';
import '../../domain/repositories/i_cycle_repository.dart';
import '../../domain/services/cycle_service.dart';

class CycleStateModel {
  final CycleRecord? latestRecord;
  final CycleDayState? currentState;
  final bool isLoading;
  final String? errorMessage;

  const CycleStateModel({
    this.latestRecord,
    this.currentState,
    this.isLoading = false,
    this.errorMessage,
  });

  CycleStateModel copyWith({
    CycleRecord? latestRecord,
    CycleDayState? currentState,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CycleStateModel(
      latestRecord: latestRecord ?? this.latestRecord,
      currentState: currentState ?? this.currentState,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CycleNotifier extends Notifier<CycleStateModel> {
  ICycleRepository? _repository;
  late final CycleService _cycleService;

  @override
  CycleStateModel build() {
    _cycleService = ref.watch(cycleServiceProvider);
    ref.listen(cycleRepositoryProvider, (previous, next) {
      next.whenData((repo) {
        _repository = repo;
        loadCycle();
      });
    });

    final currentRepo = ref.watch(cycleRepositoryProvider).value;
    if (currentRepo != null) {
      _repository = currentRepo;
      Future.microtask(() => loadCycle());
    }

    return const CycleStateModel();
  }

  Future<void> loadCycle() async {
    final ICycleRepository repo = _repository ?? await ref.read(cycleRepositoryProvider.future);
    _repository = repo;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await repo.getLatestCycleLog();
    res.fold(
      onOk: (record) {
        if (record != null) {
          final stateRes = _cycleService.calculateCycleState(
            lastPeriodStart: record.periodStart,
            cycleLength: record.cycleLength,
          );
          state = state.copyWith(
            latestRecord: record,
            currentState: stateRes.valueOrNull,
            isLoading: false,
          );
        } else {
          state = state.copyWith(isLoading: false);
        }
      },
      onErr: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
      },
    );
  }

  Future<Result<void>> logPeriodStart(
    DateTime periodStart, {
    int cycleLength = 28,
    int? flowDuration,
  }) async {
    final ICycleRepository repo = _repository ?? await ref.read(cycleRepositoryProvider.future);
    _repository = repo;
    state = state.copyWith(isLoading: true);
    final now = DateTime.now();
    final periodEnd = flowDuration != null
        ? periodStart.add(Duration(days: flowDuration))
        : null;
    final record = CycleRecord(
      id: 'cycle_${now.millisecondsSinceEpoch}',
      periodStart: periodStart,
      periodEnd: periodEnd,
      cycleLength: cycleLength,
      createdAt: now,
      updatedAt: now,
    );

    final res = await repo.saveCycleLog(record);
    if (res.isOk) {
      final stateRes = _cycleService.calculateCycleState(
        lastPeriodStart: periodStart,
        cycleLength: cycleLength,
      );
      state = state.copyWith(
        latestRecord: record,
        currentState: stateRes.valueOrNull,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: res.failureOrNull?.message);
    }
    return res;
  }

  Future<Result<void>> logPeriodEnd(
    DateTime periodEnd, {
    required int flowDuration,
    int cycleLength = 28,
  }) async {
    final periodStart = periodEnd.subtract(Duration(days: flowDuration - 1));
    return await logPeriodStart(
      periodStart,
      cycleLength: cycleLength,
      flowDuration: flowDuration,
    );
  }
}

final cycleNotifierProvider = NotifierProvider<CycleNotifier, CycleStateModel>(CycleNotifier.new);
