import 'package:equatable/equatable.dart';

/// Shopping checklist item.
class ShoppingListItem extends Equatable {
  final String id;
  final String foodId;
  final String name;
  final double quantity;
  final String unit;
  final List<String> sourceRecipeIds;
  final bool isChecked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShoppingListItem({
    required this.id,
    required this.foodId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.sourceRecipeIds = const [],
    this.isChecked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  ShoppingListItem copyWith({
    String? id,
    String? foodId,
    String? name,
    double? quantity,
    String? unit,
    List<String>? sourceRecipeIds,
    bool? isChecked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      sourceRecipeIds: sourceRecipeIds ?? this.sourceRecipeIds,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        foodId,
        name,
        quantity,
        unit,
        sourceRecipeIds,
        isChecked,
        createdAt,
        updatedAt,
      ];
}
