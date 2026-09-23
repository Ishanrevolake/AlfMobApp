import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../client_profile/data/models/profile_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

final clientsRepositoryProvider = Provider<ClientsRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ClientsRepository(supabase);
});

class ClientsRepository {
  final SupabaseClient _supabase;

  ClientsRepository(this._supabase);

  Future<List<ClientProfile>> getClients() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'client')
          .order('full_name', ascending: true);

      return data.map((json) => ClientProfile.fromJson(json)).toList();
    } catch (e) {
      // Mock data if table fails
      return [
        ClientProfile(
          id: '1',
          fullName: 'Sarah Connor',
          email: 'sarah@example.com',
          role: 'client',
        ),
        ClientProfile(
          id: '2',
          fullName: 'John Doe',
          email: 'john@example.com',
          role: 'client',
        ),
      ];
    }
  }
}
