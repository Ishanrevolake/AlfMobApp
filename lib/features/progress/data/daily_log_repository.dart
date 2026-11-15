import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

final dailyLogRepositoryProvider = Provider(
  (ref) => DailyLogRepository(ref.watch(supabaseProvider)),
);

String logDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class DailyLogRepository {
  final SupabaseClient client;
  DailyLogRepository(this.client);

  Future<Map<String, Map<String, dynamic>>> read(
    String clientId,
    DateTime date,
    String kind,
  ) async {
    final rows = await client
        .from('client_daily_logs')
        .select()
        .eq('client_id', clientId)
        .eq('log_date', logDate(date))
        .eq('kind', kind);
    return {
      for (final row in rows)
        row['item_id'] as String: Map<String, dynamic>.from(
          row['payload'] as Map,
        ),
    };
  }

  Future<void> save(
    String clientId,
    DateTime date,
    String kind,
    String itemId,
    Map<String, dynamic> payload,
  ) async {
    await client.from('client_daily_logs').upsert({
      'client_id': clientId,
      'log_date': logDate(date),
      'kind': kind,
      'item_id': itemId,
      'payload': payload,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'client_id,log_date,kind,item_id');
  }
}
