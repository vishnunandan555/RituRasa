import 'package:equatable/equatable.dart';

/// Supported dietary types.
enum DietType {
  vegetarian,
  vegan,
  nonVegetarian,
  eggetarian,
  jain,
  pescatarian;

  static DietType fromString(String value) {
    return DietType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase().replaceAll('-', '').replaceAll('_', ''),
      orElse: () => DietType.vegetarian,
    );
  }
}

/// Authoritative local user profile entity.
class UserProfile extends Equatable {
  final String id;
  final int age;
  final DietType dietType;
  final String region;
  final String cuisine;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.age,
    required this.dietType,
    required this.region,
    required this.cuisine,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    int? age,
    DietType? dietType,
    String? region,
    String? cuisine,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      age: age ?? this.age,
      dietType: dietType ?? this.dietType,
      region: region ?? this.region,
      cuisine: cuisine ?? this.cuisine,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'age': age,
      'diet_type': dietType.name,
      'region': region,
      'cuisine': cuisine,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      age: (map['age'] as num).toInt(),
      dietType: DietType.fromString(map['diet_type'] as String? ?? 'vegetarian'),
      region: map['region'] as String? ?? '',
      cuisine: map['cuisine'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, age, dietType, region, cuisine, createdAt, updatedAt];
}

/// User food preferences, exclusions, and allergies.
class UserPreferences extends Equatable {
  final String userId;
  final List<String> preferredFoodIds;
  final List<String> excludedFoodIds;
  final List<String> allergies;
  final DateTime updatedAt;

  const UserPreferences({
    required this.userId,
    this.preferredFoodIds = const [],
    this.excludedFoodIds = const [],
    this.allergies = const [],
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [userId, preferredFoodIds, excludedFoodIds, allergies, updatedAt];
}
