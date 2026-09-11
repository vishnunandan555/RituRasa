import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/dependency_providers.dart';
import '../../domain/models/recommendation.dart';
import '../../domain/services/recommendation_engine.dart';

class RecommendationState {
  final RecommendationResult? result;
  final bool isLoading;
  final String? errorMessage;

  const RecommendationState({
    this.result,
    this.isLoading = false,
    this.errorMessage,
  });

  RecommendationState copyWith({
    RecommendationResult? result,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RecommendationState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class RecommendationNotifier extends Notifier<RecommendationState> {
  late final RecommendationEngine _engine;

  @override
  RecommendationState build() {
    ref.watch(recommendationEngineProvider).whenData((engine) {
      _engine = engine;
      refreshRecommendations();
    });
    return const RecommendationState();
  }

  Future<void> refreshRecommendations({bool forceRemote = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _engine.getRecommendations(forceRemote: forceRemote);
    res.fold(
      onOk: (data) => state = state.copyWith(result: data, isLoading: false),
      onErr: (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
    );
  }
}

final recommendationNotifierProvider =
    NotifierProvider<RecommendationNotifier, RecommendationState>(RecommendationNotifier.new);
