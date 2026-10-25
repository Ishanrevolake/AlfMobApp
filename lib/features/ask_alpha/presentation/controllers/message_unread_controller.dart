import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/models/ask_alpha_models.dart';
import '../../data/repositories/ask_alpha_repository.dart';

String messageReadKey(String userId, String threadId) =>
    'messageRead:$userId:$threadId';

bool hasUnreadTrainerMessage(
  Iterable<AskAlphaMessage> messages,
  DateTime? readThrough,
) => messages.any(
  (message) =>
      message.senderRole != 'client' &&
      (readThrough == null || message.createdAt.isAfter(readThrough)),
);

final unreadTrainerMessagesProvider = StreamProvider.autoDispose<bool>((
  ref,
) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield false;
    return;
  }
  final repository = ref.watch(askAlphaRepositoryProvider);
  var disposed = false;
  final stop = Completer<void>();
  ref.onDispose(() {
    disposed = true;
    stop.complete();
  });
  while (!disposed) {
    final preferences = await SharedPreferences.getInstance();
    final messages = await repository.getIncomingMessages(user.id);
    if (disposed) return;
    yield messages.any(
      (message) => hasUnreadTrainerMessage(
        [message],
        DateTime.tryParse(
          preferences.getString(messageReadKey(user.id, message.threadId)) ??
              '',
        ),
      ),
    );
    await Future.any([
      Future<void>.delayed(const Duration(seconds: 30)),
      stop.future,
    ]);
  }
});

Future<void> markTrainerMessagesRead(
  String userId,
  String threadId,
  Iterable<AskAlphaMessage> messages,
) async {
  final incoming = messages.where((message) => message.senderRole != 'client');
  if (incoming.isEmpty) return;
  final latest = incoming
      .map((message) => message.createdAt)
      .reduce((a, b) => a.isAfter(b) ? a : b);
  final preferences = await SharedPreferences.getInstance();
  final key = messageReadKey(userId, threadId);
  final previous = DateTime.tryParse(preferences.getString(key) ?? '');
  if (previous == null || latest.isAfter(previous)) {
    if (!await preferences.setString(key, latest.toIso8601String())) {
      throw StateError('Unable to save message read status.');
    }
  }
}
