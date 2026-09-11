import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/dependency_providers.dart';
import '../../core/errors/failure.dart';
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
  IKitchenRepository? _kitchenRepository;
  IFoodRepository? _foodRepository;

  static final List<KitchenItem> defaultStaples = [
    KitchenItem(
      id: 'k_1',
      foodId: 'F001',
      foodName: 'Fresh Spinach (Palak)',
      quantity: 2.0,
      unit: 'bunches',
      addedAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
    KitchenItem(
      id: 'k_2',
      foodId: 'F002',
      foodName: 'Yellow Moong Dal (Split)',
      quantity: 500.0,
      unit: 'g',
      addedAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
    KitchenItem(
      id: 'k_3',
      foodId: 'F003',
      foodName: 'Ragi Flour (Finger Millet)',
      quantity: 1.0,
      unit: 'kg',
      addedAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
    KitchenItem(
      id: 'k_4',
      foodId: 'F004',
      foodName: 'Desi Cow Ghee',
      quantity: 250.0,
      unit: 'ml',
      addedAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
    KitchenItem(
      id: 'k_5',
      foodId: 'F005',
      foodName: 'Black Sesame Seeds (Til)',
      quantity: 100.0,
      unit: 'g',
      addedAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
    KitchenItem(
      id: 'k_6',
      foodId: 'F006',
      foodName: 'Country Tomatoes',
      quantity: 500.0,
      unit: 'g',
      addedAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
    KitchenItem(
      id: 'k_7',
      foodId: 'F007',
      foodName: 'Jeera (Cumin Seeds)',
      quantity: 100.0,
      unit: 'g',
      addedAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
    KitchenItem(
      id: 'k_8',
      foodId: 'F008',
      foodName: 'Turmeric Powder (Haldi)',
      quantity: 100.0,
      unit: 'g',
      addedAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
  ];

  @override
  KitchenState build() {
    ref.watch(kitchenRepositoryProvider).whenData((kRepo) {
      _kitchenRepository = kRepo;
      loadInventory();
    });
    ref.watch(foodRepositoryProvider).whenData((fRepo) {
      _foodRepository = fRepo;
    });
    return KitchenState(items: defaultStaples);
  }

  Future<void> loadInventory() async {
    final repo = _kitchenRepository;
    if (repo == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await repo.getInventory();
    res.fold(
      onOk: (items) {
        state = state.copyWith(
          items: items.isNotEmpty ? items : defaultStaples,
          isLoading: false,
        );
      },
      onErr: (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
    );
  }

  Future<void> searchFoods(String query) async {
    final repo = _foodRepository;
    if (repo == null || query.trim().isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }
    final res = await repo.searchFoods(query, limit: 15);
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
    final repo = _kitchenRepository;
    if (repo == null) {
      return Result.err(DatabaseFailure(message: 'Kitchen repository not ready'));
    }
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

    final res = await repo.addItem(item);
    if (res.isOk) {
      await loadInventory();
    }
    return res;
  }

  Future<Result<void>> removeItem(String foodId) async {
    final repo = _kitchenRepository;
    if (repo == null) {
      return Result.err(DatabaseFailure(message: 'Kitchen repository not ready'));
    }
    final res = await repo.removeItem(foodId);
    if (res.isOk) {
      await loadInventory();
    }
    return res;
  }

  Future<Result<void>> updateQuantity(String foodId, double newQuantity) async {
    if (newQuantity <= 0) {
      return removeItem(foodId);
    }
    final repo = _kitchenRepository;
    if (repo == null) {
      return Result.err(DatabaseFailure(message: 'Kitchen repository not ready'));
    }
    final res = await repo.updateItemQuantity(foodId, newQuantity);
    if (res.isOk) {
      await loadInventory();
    }
    return res;
  }
}

final kitchenNotifierProvider = NotifierProvider<KitchenNotifier, KitchenState>(KitchenNotifier.new);
