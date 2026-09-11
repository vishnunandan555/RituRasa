import 'dart:convert';
import '../../core/utils/result.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../local/dao/profile_dao.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final ProfileDao profileDao;

  const ProfileRepositoryImpl(this.profileDao);

  @override
  Future<Result<UserProfile?>> getProfile() async {
    final result = await profileDao.getProfile();
    return result.map((data) {
      if (data == null) return null;
      return UserProfile.fromMap(data);
    });
  }

  @override
  Future<Result<void>> saveProfile(UserProfile profile) async {
    return await profileDao.upsertProfile(profile.toMap());
  }

  @override
  Future<Result<UserPreferences?>> getPreferences(String userId) async {
    final result = await profileDao.getPreferences(userId);
    return result.map((data) {
      if (data == null) return null;
      List<String> parseList(dynamic raw) {
        if (raw == null) return [];
        try {
          final decoded = jsonDecode(raw.toString());
          if (decoded is List) return decoded.map((e) => e.toString()).toList();
        } catch (_) {}
        return [];
      }

      return UserPreferences(
        userId: data['user_id'] as String,
        preferredFoodIds: parseList(data['preferred_food_ids_json']),
        excludedFoodIds: parseList(data['excluded_food_ids_json']),
        allergies: parseList(data['allergies_json']),
        updatedAt: DateTime.tryParse(data['updated_at']?.toString() ?? '') ?? DateTime.now(),
      );
    });
  }

  @override
  Future<Result<void>> savePreferences(UserPreferences preferences) async {
    return await profileDao.upsertPreferences({
      'user_id': preferences.userId,
      'preferred_food_ids_json': jsonEncode(preferences.preferredFoodIds),
      'excluded_food_ids_json': jsonEncode(preferences.excludedFoodIds),
      'allergies_json': jsonEncode(preferences.allergies),
      'updated_at': preferences.updatedAt.toIso8601String(),
    });
  }
}
