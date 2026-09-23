import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/profile_models.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileState {
  final ClientProfile? profile;
  final bool notifSessionReminders;
  final bool notifAskAlpha;

  ProfileState({
    this.profile,
    this.notifSessionReminders = true,
    this.notifAskAlpha = true,
  });

  ProfileState copyWith({
    ClientProfile? profile,
    bool? notifSessionReminders,
    bool? notifAskAlpha,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      notifSessionReminders:
          notifSessionReminders ?? this.notifSessionReminders,
      notifAskAlpha: notifAskAlpha ?? this.notifAskAlpha,
    );
  }
}

class ProfileController extends AsyncNotifier<ProfileState> {
  late ProfileRepository _repository;
  late String _userId;

  @override
  FutureOr<ProfileState> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return ProfileState();

    _userId = user.id;
    _repository = ref.watch(profileRepositoryProvider);

    final profile = await _repository.getProfile(_userId);
    final settings = await _repository.getNotificationSettings(_userId);
    return ProfileState(
      profile: profile,
      notifSessionReminders: settings.$1,
      notifAskAlpha: settings.$2,
    );
  }

  Future<void> toggleReminder(bool value) async {
    if (state.value == null) return;
    state = AsyncData(state.value!.copyWith(notifSessionReminders: value));
    await _repository.updateNotificationSettings(
      _userId,
      value,
      state.value!.notifAskAlpha,
    );
  }

  Future<void> toggleAskAlphaAlert(bool value) async {
    if (state.value == null) return;
    state = AsyncData(state.value!.copyWith(notifAskAlpha: value));
    await _repository.updateNotificationSettings(
      _userId,
      state.value!.notifSessionReminders,
      value,
    );
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileState>(() {
      return ProfileController();
    });
