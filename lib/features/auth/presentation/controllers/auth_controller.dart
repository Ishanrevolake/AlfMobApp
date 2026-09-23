import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user ??
      ref.watch(supabaseProvider).auth.currentUser;
});

final userRoleProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 'unauthenticated';

  // Role resolution order:
  // 1. profiles.role
  // 2. Auth app_metadata.role
  // 3. Auth user_metadata.role
  // 4. Default client

  final supabase = ref.watch(supabaseProvider);
  try {
    final profile = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    if (profile != null && profile['role'] != null) {
      final role = profile['role'].toString().toLowerCase();
      if (role == 'user' || role == 'normal') return 'client';
      return role;
    }
  } catch (_) {
    // Fallback to metadata
  }

  final appMetadataRole =
      user.appMetadata['role'] ?? user.appMetadata['user_role'];
  if (appMetadataRole != null) {
    final role = appMetadataRole.toString().toLowerCase();
    if (role == 'user' || role == 'normal') return 'client';
    return role;
  }

  final userMetadataRole =
      user.userMetadata?['role'] ?? user.userMetadata?['user_role'];
  if (userMetadataRole != null) {
    final role = userMetadataRole.toString().toLowerCase();
    if (role == 'user' || role == 'normal') return 'client';
    return role;
  }

  return 'client';
});
