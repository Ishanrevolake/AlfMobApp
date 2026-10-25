import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../models/ask_alpha_models.dart';

final askAlphaRepositoryProvider = Provider<AskAlphaRepository>((ref) {
  return AskAlphaRepository(ref.watch(supabaseProvider));
});

class AskAlphaRepository {
  final SupabaseClient _supabase;

  AskAlphaRepository(this._supabase);

  Future<List<AskAlphaOrder>> getOrders(String userId) async {
    final response = await _supabase
        .from('ask_alpha_orders')
        .select()
        .eq('user_id', userId)
        .order('submitted_at', ascending: false);
    return response.map((data) => AskAlphaOrder.fromJson(data)).toList();
  }

  Future<List<AskAlphaThread>> getThreads(String userId) async {
    final response = await _supabase
        .from('ask_alpha_threads')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    return response.map((data) => AskAlphaThread.fromJson(data)).toList();
  }

  Future<AskAlphaThread> createClientConversation(String userId) async {
    final data = await _supabase
        .from('ask_alpha_threads')
        .insert({
          'user_id': userId,
          'subject': 'Message Alpha',
          'status': 'open',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
    return AskAlphaThread.fromJson(data);
  }

  Future<void> submitOrder({
    required String userId,
    required String pack,
    required String title,
    required int credits,
    required num amount,
    File? paymentSlip,
  }) async {
    String? slipPath;
    if (paymentSlip != null) {
      final extension = paymentSlip.path.split('.').last.toLowerCase();
      slipPath = '$userId/${DateTime.now().millisecondsSinceEpoch}.$extension';
      await _supabase.storage
          .from('payment-slips')
          .upload(
            slipPath,
            paymentSlip,
            fileOptions: const FileOptions(upsert: false),
          );
    }

    await _supabase.from('ask_alpha_orders').insert({
      'user_id': userId,
      'product_id': pack,
      'product_title': title,
      'question_credits': credits,
      'amount_lkr': amount,
      'method': 'bank_transfer',
      'reference': 'APP-${DateTime.now().millisecondsSinceEpoch}',
      'status': 'pending_verification',
      'slip_file_name': paymentSlip?.path.split(Platform.pathSeparator).last,
      'slip_storage_path': slipPath,
      'submitted_at': DateTime.now().toIso8601String(),
    });
  }

  Future<AskAlphaThread> submitQuestion({
    required String userId,
    required AskAlphaOrder order,
    required String question,
  }) async {
    final threadData = await _supabase
        .from('ask_alpha_threads')
        .insert({
          'order_id': order.id,
          'user_id': userId,
          'subject': question.length > 72
              ? '${question.substring(0, 72)}â€¦'
              : question,
          'status': 'open',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
    final thread = AskAlphaThread.fromJson(threadData);
    await sendMessage(thread.id, userId, question, senderRole: 'client');
    return thread;
  }

  Future<List<AskAlphaMessage>> getMessages(String threadId) async {
    final response = await _supabase
        .from('ask_alpha_messages')
        .select()
        .eq('thread_id', threadId)
        .order('created_at');
    return response.map((data) => AskAlphaMessage.fromJson(data)).toList();
  }

  Future<List<AskAlphaMessage>> getIncomingMessages(String userId) async {
    final threads = await getThreads(userId);
    if (threads.isEmpty) return [];
    final response = await _supabase
        .from('ask_alpha_messages')
        .select()
        .inFilter('thread_id', threads.map((thread) => thread.id).toList())
        .neq('sender_role', 'client');
    return response.map((data) => AskAlphaMessage.fromJson(data)).toList();
  }

  Future<void> sendMessage(
    String threadId,
    String senderId,
    String content, {
    String senderRole = 'client',
  }) async {
    await _supabase.from('ask_alpha_messages').insert({
      'thread_id': threadId,
      'sender_id': senderId,
      'sender_role': senderRole,
      'body': content,
    });
    await _supabase
        .from('ask_alpha_threads')
        .update({
          'updated_at': DateTime.now().toIso8601String(),
          'status': senderRole == 'client' ? 'open' : 'answered',
        })
        .eq('id', threadId);
  }

  Stream<List<AskAlphaMessage>> messagesStream(String threadId) => _supabase
      .from('ask_alpha_messages')
      .stream(primaryKey: ['id'])
      .eq('thread_id', threadId)
      .order('created_at')
      .map((data) => data.map(AskAlphaMessage.fromJson).toList());
}
