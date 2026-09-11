import 'package:equatable/equatable.dart';

/// Kitchen pantry inventory item.
class KitchenItem extends Equatable {
  final String id;
  final String foodId;
  final String? foodName;
  final String? category;
  final double quantity;
  final String unit;
  final DateTime addedAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  const KitchenItem({
    required this.id,
    required this.foodId,
    this.foodName,
    this.category,
    required this.quantity,
    required this.unit,
    required this.addedAt,
    required this.updatedAt,
    this.expiresAt,
  });

  KitchenItem copyWith({
    String? id,
    String? foodId,
    String? foodName,
    String? category,
    double? quantity,
    String? unit,
    DateTime? addedAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return KitchenItem(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  List<Object?> get props => [id, foodId, foodName, category, quantity, unit, addedAt, updatedAt, expiresAt];
}
