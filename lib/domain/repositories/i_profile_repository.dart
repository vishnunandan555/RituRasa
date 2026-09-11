import '../../../core/utils/result.dart';
import '../models/user_profile.dart';

/// Repository interface for user profile and dietary constraints.
abstract class IProfileRepository {
  Future<Result<UserProfile?>> getProfile();
  Future<Result<void>> saveProfile(UserProfile profile);
  Future<Result<UserPreferences?>> getPreferences(String userId);
  Future<Result<void>> savePreferences(UserPreferences preferences);
}
