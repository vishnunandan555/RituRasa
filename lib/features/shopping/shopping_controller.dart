import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/dependency_providers.dart';
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
  late final IShoppingRepository _shoppingRepository;

  @override
  ShoppingState build() {
    ref.watch(shoppingRepositoryProvider).whenData((repo) {
      _shoppingRepository = repo;
      loadShoppingList();
    });
    return const ShoppingState();
  }

  Future<void> loadShoppingList() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _shoppingRepository.getShoppingList();
    res.fold(
      onOk: (items) => state = state.copyWith(items: items, isLoading: false),
      onErr: (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
    );
  }

  Future<Result<void>> toggleChecked(String id, bool isChecked) async {
    final res = await _shoppingRepository.toggleChecked(id, isChecked);
    if (res.isOk) {
      await loadShoppingList();
    }
    return res;
  }

  Future<Result<void>> deleteItem(String id) async {
    final res = await _shoppingRepository.deleteItem(id);
    if (res.isOk) {
      await loadShoppingList();
    }
    return res;
  }

  Future<Result<void>> clearChecked() async {
    final res = await _shoppingRepository.removeChecked();
    if (res.isOk) {
      await loadShoppingList();
    }
    return res;
  }
}

final shoppingNotifierProvider =
    NotifierProvider<ShoppingNotifier, ShoppingState>(ShoppingNotifier.new);
