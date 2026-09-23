import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ProfileRepository(supabase);
});

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  Future<ClientProfile?> getProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return ClientProfile.fromJson(data);
    } catch (_) {
      final user = _supabase.auth.currentUser;
      final metadata = user?.userMetadata ?? const <String, dynamic>{};
      return ClientProfile(
        id: userId,
        fullName:
            (metadata['full_name'] ??
                    metadata['name'] ??
                    user?.email?.split('@').first ??
                    'Client')
                .toString(),
        email: user?.email ?? '',
        role: (metadata['role'] ?? 'client').toString(),
      );
    }
  }

  Future<void> updateNotificationSettings(
    String userId,
    bool reminders,
    bool askAlpha,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('session_reminders_$userId', reminders);
    await preferences.setBool('ask_alpha_alerts_$userId', askAlpha);
  }

  Future<(bool, bool)> getNotificationSettings(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    return (
      preferences.getBool('session_reminders_$userId') ?? true,
      preferences.getBool('ask_alpha_alerts_$userId') ?? true,
    );
  }
}
