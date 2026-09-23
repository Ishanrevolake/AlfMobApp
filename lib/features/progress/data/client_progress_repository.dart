import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final clientProgressRepositoryProvider = Provider<ClientProgressRepository>(
  (ref) => ClientProgressRepository(),
);

/// Personal check-offs are device-local. They never write trainer-owned plans.
/// The week and plan start date prevent old completions carrying into new plans.
class ClientProgressRepository {
  final DateTime Function() now;
  ClientProgressRepository({DateTime Function()? now})
    : now = now ?? DateTime.now;

  String key(
    String clientId,
    String kind,
    DateTime startDate,
    String dayId,
    String itemId,
  ) {
    final today = now();
    final monday = DateTime(
      today.year,
      today.month,
      today.day - today.weekday + 1,
    );
    return 'clientProgress:${jsonEncode([clientId, kind, monday.toIso8601String().split('T').first, startDate.toIso8601String().split('T').first, dayId, itemId])}';
  }

  Future<Map<String, bool>> read(Iterable<String> keys) async {
    final preferences = await SharedPreferences.getInstance();
    return {for (final key in keys) key: preferences.getBool(key) ?? false};
  }

  Future<void> write(String key, bool completed) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setBool(key, completed)) {
      throw StateError(
        'Unable to save progress on this device. Please try again.',
      );
    }
  }
}
