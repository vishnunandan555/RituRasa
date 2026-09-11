import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/dependency_providers.dart';
import '../../core/utils/result.dart';
import '../../domain/models/food.dart';
import '../../domain/models/kitchen_item.dart';
import '../../domain/repositories/i_food_repository.dart';
import '../../domain/repositories/i_kitchen_repository.dart';

class KitchenState {
  final List<KitchenItem> items;
  final List<FoodItem> searchResults;
  final bool isLoading;
  final String? errorMessage;

  const KitchenState({
    this.items = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  KitchenState copyWith({
    List<KitchenItem>? items,
    List<FoodItem>? searchResults,
    bool? isLoading,
    String? errorMessage,
  }) {
    return KitchenState(
      items: items ?? this.items,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class KitchenNotifier extends Notifier<KitchenState> {
  late final IKitchenRepository _kitchenRepository;
  late final IFoodRepository _foodRepository;

  @override
  KitchenState build() {
    ref.watch(kitchenRepositoryProvider).whenData((kRepo) {
      _kitchenRepository = kRepo;
      ref.watch(foodRepositoryProvider).whenData((fRepo) {
        _foodRepository = fRepo;
        loadInventory();
      });
    });
    return const KitchenState();
  }

  Future<void> loadInventory() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _kitchenRepository.getInventory();
    res.fold(
      onOk: (items) => state = state.copyWith(items: items, isLoading: false),
      onErr: (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
    );
  }

  Future<void> searchFoods(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }
    final res = await _foodRepository.searchFoods(query, limit: 15);
    res.fold(
      onOk: (foods) => state = state.copyWith(searchResults: foods),
      onErr: (f) => state = state.copyWith(errorMessage: f.message),
    );
  }

  Future<Result<void>> addItem({
    required String foodId,
    String? foodName,
    required double quantity,
    required String unit,
  }) async {
    final now = DateTime.now();
    final item = KitchenItem(
      id: 'k_${now.millisecondsSinceEpoch}',
      foodId: foodId,
      foodName: foodName,
      quantity: quantity,
      unit: unit,
      addedAt: now,
      updatedAt: now,
    );

    final res = await _kitchenRepository.addItem(item);
    if (res.isOk) {
      await loadInventory();
    }
    return res;
  }

  Future<Result<void>> removeItem(String foodId) async {
    final res = await _kitchenRepository.removeItem(foodId);
    if (res.isOk) {
      await loadInventory();
    }
    return res;
  }
}

final kitchenNotifierProvider = NotifierProvider<KitchenNotifier, KitchenState>(KitchenNotifier.new);
