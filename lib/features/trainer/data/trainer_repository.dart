import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import '../../client_profile/data/models/profile_models.dart';
import 'program_packages.dart';

final trainerRepositoryProvider = Provider<TrainerRepository>(
  (ref) => TrainerRepository(ref.watch(supabaseProvider)),
);

class TrainerRepository {
  final SupabaseClient supabase;
  TrainerRepository(this.supabase);

  Future<List<ManagedPackage>> getPackages() async {
    final packages = await supabase.from('packages').select().order('title');
    final clientsByPackage = <String, Set<String>>{};
    // Include every linked selection: historical records also prevent deletion
    // through the database foreign key and must not be silently discarded.
    for (var offset = 0; ; offset += 1000) {
      final selections = await supabase
          .from('package_selections')
          .select('id,package_id,user_id')
          .order('id')
          .range(offset, offset + 999);
      for (final selection in selections) {
        clientsByPackage
            .putIfAbsent(selection['package_id'] as String, () => <String>{})
            .add(selection['user_id'] as String);
      }
      if (selections.length < 1000) break;
    }
    return packages
        .map(
          (row) => ManagedPackage(
            row,
            clientCount: clientsByPackage[row['id']]?.length ?? 0,
          ),
        )
        .toList();
  }

  Future<void> savePackage({
    String? id,
    required String name,
    required String duration,
    required int price,
    required String description,
    required String category,
  }) async {
    if (name.trim().isEmpty ||
        duration.trim().isEmpty ||
        price < 0 ||
        price > 2147483647) {
      throw const PackageOperationException(
        'Enter a name, duration and valid price.',
      );
    }
    final values = <String, dynamic>{
      'title': name.trim(),
      'subtitle': duration.trim(),
      'price_lkr': price,
      'detail_subtitle': description.trim(),
      'category': category,
    };
    if (id != null) {
      final saved = await supabase
          .from('packages')
          .update(values)
          .eq('id', id)
          .select('id');
      if (saved.isEmpty) {
        throw const PackageOperationException(
          'Package could not be saved. Check your trainer access and try again.',
        );
      }
    } else {
      final suffix = Random.secure().nextInt(0x7fffffff).toRadixString(16);
      await supabase
          .from('packages')
          .insert({
            ...values,
            'id': 'package-${DateTime.now().microsecondsSinceEpoch}-$suffix',
            'letter': name.trim().substring(0, 1).toUpperCase(),
            'footer_text': '',
            'example': '',
            'features': <String>[],
            'is_active': true,
          })
          .select('id')
          .single();
    }
  }

  Future<void> deletePackage(String id) async {
    final linked = await supabase
        .from('package_selections')
        .select('id')
        .eq('package_id', id)
        .limit(1);
    if (linked.isNotEmpty) {
      throw const PackageOperationException(assignedPackageMessage);
    }
    try {
      final deleted = await supabase
          .from('packages')
          .delete()
          .eq('id', id)
          .select('id');
      if (deleted.isEmpty) {
        throw const PackageOperationException(
          'Package could not be removed. Refresh and check your trainer access.',
        );
      }
    } on PostgrestException catch (error) {
      // The FK also protects assignments created after the check above.
      if (error.code == '23503') {
        throw const PackageOperationException(assignedPackageMessage);
      }
      rethrow;
    }
  }

  Future<List<ClientProfile>> getClients() async {
    final data = await supabase
        .from('profiles')
        .select()
        // `role` is a Postgres app_role enum. Passing legacy text values such
        // as "user" or "normal" makes PostgREST reject the entire filter
        // before it can return valid client rows.
        .eq('role', 'client')
        .order('full_name');
    return data.map(ClientProfile.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> getRows(
    String table, {
    String? orderBy,
    bool ascending = false,
  }) async {
    if (orderBy == null) {
      return List<Map<String, dynamic>>.from(
        await supabase.from(table).select(),
      );
    }
    try {
      return List<Map<String, dynamic>>.from(
        await supabase
            .from(table)
            .select()
            .order(orderBy, ascending: ascending),
      );
    } catch (_) {
      return List<Map<String, dynamic>>.from(
        await supabase.from(table).select(),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getClientNotes(String clientId) async =>
      List<Map<String, dynamic>>.from(
        await supabase
            .from('client_notes')
            .select()
            .eq('client_id', clientId)
            .order('created_at', ascending: false),
      );

  Future<void> addClientNote(String clientId, String body) async {
    await supabase.from('client_notes').insert({
      'client_id': clientId,
      'body': body.trim(),
    });
  }

  Future<void> updateStatus(
    String table,
    String id,
    Map<String, dynamic> values,
  ) async {
    final result = await supabase
        .from(table)
        .update(values)
        .eq('id', id)
        .select('id')
        .maybeSingle();
    if (result == null) {
      throw StateError(
        'The update was blocked. Check the table Row Level Security policy for trainer access.',
      );
    }
  }

  Future<void> verifyPayment(String id, String trainerId) =>
      updateStatus('payments', id, {
        'status': 'verified',
        'verified_at': DateTime.now().toIso8601String(),
        'verified_by': trainerId,
      });

  Future<void> verifyAskOrder(String id, String trainerId) =>
      updateStatus('ask_alpha_orders', id, {
        'status': 'verified',
        'verified_at': DateTime.now().toIso8601String(),
        'verified_by': trainerId,
        'rejection_reason': null,
      });

  Future<void> rejectAskOrder(String id, String reason) =>
      updateStatus('ask_alpha_orders', id, {
        'status': 'rejected',
        'verified_at': null,
        'verified_by': null,
        'rejection_reason': reason,
      });

  Future<void> replyToThread({
    required String threadId,
    required String trainerId,
    required String role,
    required String body,
  }) async {
    await supabase.from('ask_alpha_messages').insert({
      'thread_id': threadId,
      'sender_id': trainerId,
      'sender_role': role == 'admin' ? 'admin' : 'coach',
      'body': body.trim(),
    });
    await updateStatus('ask_alpha_threads', threadId, {
      'status': 'answered',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> setThreadStatus(String id, String status) => updateStatus(
    'ask_alpha_threads',
    id,
    {'status': status, 'updated_at': DateTime.now().toIso8601String()},
  );

  Future<void> saveExercise(
    Map<String, dynamic> exercise, {
    bool editing = false,
  }) async {
    const baseUrl = String.fromEnvironment(
      'DASHBOARD_URL',
      defaultValue: 'https://alfdashboard.dellodigital.com',
    );
    final session = supabase.auth.currentSession;
    if (session == null) throw StateError('Sign in before saving exercises.');
    final uri = Uri.parse(
      '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/exercises',
    );
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    };
    final body = jsonEncode(exercise);
    final response =
        await (editing
                ? http.patch(uri, headers: headers, body: body)
                : http.post(uri, headers: headers, body: body))
            .timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Unable to save exercise (${response.statusCode}).';
      try {
        message =
            (jsonDecode(response.body) as Map)['message']?.toString() ??
            message;
      } catch (_) {}
      throw StateError(message);
    }
  }
}
