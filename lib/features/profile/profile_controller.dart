import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/dependency_providers.dart';
import '../../core/utils/result.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/i_profile_repository.dart';

class ProfileState {
  final UserProfile? profile;
  final UserPreferences? preferences;
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({
    this.profile,
    this.preferences,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    UserProfile? profile,
    UserPreferences? preferences,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  IProfileRepository? _repository;

  @override
  ProfileState build() {
    ref.listen(profileRepositoryProvider, (previous, next) {
      next.whenData((repo) {
        _repository = repo;
        loadProfile();
      });
    });

    final currentRepo = ref.watch(profileRepositoryProvider).value;
    if (currentRepo != null) {
      _repository = currentRepo;
      Future.microtask(() => loadProfile());
    }

    return const ProfileState();
  }

  Future<void> loadProfile() async {
    final IProfileRepository repo = _repository ?? await ref.read(profileRepositoryProvider.future);
    _repository = repo;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await repo.getProfile();
    res.fold(
      onOk: (profile) async {
        if (profile != null) {
          final prefRes = await repo.getPreferences(profile.id);
          state = state.copyWith(
            profile: profile,
            preferences: prefRes.valueOrNull,
            isLoading: false,
          );
        } else {
          state = state.copyWith(isLoading: false);
        }
      },
      onErr: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
      },
    );
  }

  Future<Result<void>> updateProfile(UserProfile profile) async {
    final IProfileRepository repo = _repository ?? await ref.read(profileRepositoryProvider.future);
    _repository = repo;
    state = state.copyWith(isLoading: true);
    final res = await repo.saveProfile(profile);
    if (res.isOk) {
      state = state.copyWith(profile: profile, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: res.failureOrNull?.message);
    }
    return res;
  }

  Future<Result<void>> updatePreferences(UserPreferences preferences) async {
    final IProfileRepository repo = _repository ?? await ref.read(profileRepositoryProvider.future);
    _repository = repo;
    state = state.copyWith(isLoading: true);
    final res = await repo.savePreferences(preferences);
    if (res.isOk) {
      state = state.copyWith(preferences: preferences, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: res.failureOrNull?.message);
    }
    return res;
  }
}

final profileNotifierProvider = NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);
