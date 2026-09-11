import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/dependency_providers.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/result.dart';
import '../../domain/models/shopping_item.dart';
import '../../domain/repositories/i_shopping_repository.dart';

class ShoppingState {
  final List<ShoppingListItem> items;
  final bool isLoading;
  final String? errorMessage;

  const ShoppingState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ShoppingState copyWith({
    List<ShoppingListItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ShoppingState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ShoppingNotifier extends Notifier<ShoppingState> {
  IShoppingRepository? _shoppingRepository;

  static final List<ShoppingListItem> defaultCartItems = [
    ShoppingListItem(
      id: 's_1',
      foodId: 'F020',
      name: 'Fresh Lemon Juice',
      quantity: 100.0,
      unit: 'ml',
      isChecked: false,
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
    ShoppingListItem(
      id: 's_2',
      foodId: 'F021',
      name: 'Cold Pressed Mustard Oil',
      quantity: 500.0,
      unit: 'ml',
      isChecked: false,
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
    ShoppingListItem(
      id: 's_3',
      foodId: 'F022',
      name: 'Organic Pumpkin Seeds',
      quantity: 200.0,
      unit: 'g',
      isChecked: true,
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
  ];

  @override
  ShoppingState build() {
    ref.watch(shoppingRepositoryProvider).whenData((repo) {
      _shoppingRepository = repo;
      loadShoppingList();
    });
    return ShoppingState(items: defaultCartItems);
  }

  Future<void> loadShoppingList() async {
    final repo = _shoppingRepository;
    if (repo == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await repo.getShoppingList();
    res.fold(
      onOk: (items) {
        state = state.copyWith(
          items: items.isNotEmpty ? items : defaultCartItems,
          isLoading: false,
        );
      },
      onErr: (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
    );
  }

  Future<Result<void>> addItem({
    required String foodId,
    required String name,
    required double quantity,
    required String unit,
    List<String> sourceRecipeIds = const [],
  }) async {
    final repo = _shoppingRepository;
    final now = DateTime.now();
    final item = ShoppingListItem(
      id: 's_${now.millisecondsSinceEpoch}',
      foodId: foodId,
      name: name,
      quantity: quantity,
      unit: unit,
      sourceRecipeIds: sourceRecipeIds,
      isChecked: false,
      createdAt: now,
      updatedAt: now,
    );

    if (repo == null) {
      final updated = [...state.items, item];
      state = state.copyWith(items: updated);
      return Result.ok(null);
    }

    final res = await repo.addItem(item);
    if (res.isOk) {
      await loadShoppingList();
    }
    return res;
  }

  Future<Result<void>> addItems(List<ShoppingListItem> items) async {
    final repo = _shoppingRepository;
    if (repo == null) {
      final updated = [...state.items, ...items];
      state = state.copyWith(items: updated);
      return Result.ok(null);
    }
    final res = await repo.addItems(items);
    if (res.isOk) {
      await loadShoppingList();
    }
    return res;
  }

  Future<Result<void>> toggleChecked(String id, bool isChecked) async {
    final repo = _shoppingRepository;
    if (repo == null) {
      final updated = state.items.map((i) => i.id == id ? i.copyWith(isChecked: isChecked) : i).toList();
      state = state.copyWith(items: updated);
      return Result.ok(null);
    }
    final res = await repo.toggleChecked(id, isChecked);
    if (res.isOk) {
      await loadShoppingList();
    }
    return res;
  }

  Future<Result<void>> deleteItem(String id) async {
    final repo = _shoppingRepository;
    if (repo == null) {
      final updated = state.items.where((i) => i.id != id).toList();
      state = state.copyWith(items: updated);
      return Result.ok(null);
    }
    final res = await repo.deleteItem(id);
    if (res.isOk) {
      await loadShoppingList();
    }
    return res;
  }

  Future<Result<void>> clearChecked() async {
    final repo = _shoppingRepository;
    if (repo == null) {
      final updated = state.items.where((i) => !i.isChecked).toList();
      state = state.copyWith(items: updated);
      return Result.ok(null);
    }
    final res = await repo.removeChecked();
    if (res.isOk) {
      await loadShoppingList();
    }
    return res;
  }
}

final shoppingNotifierProvider =
    NotifierProvider<ShoppingNotifier, ShoppingState>(ShoppingNotifier.new);
