import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alfalee_app/features/progress/data/daily_log_repository.dart';

class MemoryDailyLogs extends DailyLogRepository {
  MemoryDailyLogs()
    : super(
        SupabaseClient(
          'https://example.supabase.co',
          'test',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );
  final values = <String, Map<String, Map<String, dynamic>>>{};
  bool fail = false;
  String key(String clientId, DateTime date, String kind) =>
      '$clientId:${logDate(date)}:$kind';
  @override
  Future<Map<String, Map<String, dynamic>>> read(
    String clientId,
    DateTime date,
    String kind,
  ) async {
    if (fail) throw StateError('offline');
    return Map.from(values[key(clientId, date, kind)] ?? {});
  }

  @override
  Future<void> save(
    String clientId,
    DateTime date,
    String kind,
    String itemId,
    Map<String, dynamic> payload,
  ) async {
    if (fail) throw StateError('offline');
    (values[key(clientId, date, kind)] ??= {})[itemId] = Map.from(payload);
  }
}
