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
  final String name;
  final int age;
  final String prakriti;
  final String agni;
  final DietType dietType;
  final String region;
  final String cuisine;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.name = 'Ananya Sharma',
    required this.age,
    this.prakriti = 'Pitta-Vata',
    this.agni = 'Tikshna',
    required this.dietType,
    required this.region,
    required this.cuisine,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? prakriti,
    String? agni,
    DietType? dietType,
    String? region,
    String? cuisine,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      prakriti: prakriti ?? this.prakriti,
      agni: agni ?? this.agni,
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
      'name': name,
      'age': age,
      'prakriti': prakriti,
      'agni': agni,
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
      name: map['name'] as String? ?? 'Ananya Sharma',
      age: (map['age'] as num).toInt(),
      prakriti: map['prakriti'] as String? ?? 'Pitta-Vata',
      agni: map['agni'] as String? ?? 'Tikshna',
      dietType: DietType.fromString(map['diet_type'] as String? ?? 'vegetarian'),
      region: map['region'] as String? ?? '',
      cuisine: map['cuisine'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, name, age, prakriti, agni, dietType, region, cuisine, createdAt, updatedAt];
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

  UserPreferences copyWith({
    String? userId,
    List<String>? preferredFoodIds,
    List<String>? excludedFoodIds,
    List<String>? allergies,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      preferredFoodIds: preferredFoodIds ?? this.preferredFoodIds,
      excludedFoodIds: excludedFoodIds ?? this.excludedFoodIds,
      allergies: allergies ?? this.allergies,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [userId, preferredFoodIds, excludedFoodIds, allergies, updatedAt];
}
