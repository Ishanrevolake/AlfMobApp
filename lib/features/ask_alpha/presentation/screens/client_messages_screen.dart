import 'package:flutter/material.dart';
import 'message_attachment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/alf_widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/models/ask_alpha_models.dart';
import '../../data/repositories/ask_alpha_repository.dart';

final clientMessagesProvider = FutureProvider.autoDispose<List<AskAlphaThread>>(
  (ref) async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];
    return ref.watch(askAlphaRepositoryProvider).getThreads(user.id);
  },
);

class ClientMessagesScreen extends ConsumerStatefulWidget {
  const ClientMessagesScreen({super.key});
  @override
  ConsumerState<ClientMessagesScreen> createState() => _MessagesState();
}

class _MessagesState extends ConsumerState<ClientMessagesScreen> {
  final message = TextEditingController();
  bool sending = false;
  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final threads = ref.watch(clientMessagesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('MESSAGES')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Message Alpha',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          Expanded(
            child: threads.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AlfAsyncError(
                error: error,
                onRetry: () => ref.invalidate(clientMessagesProvider),
              ),
              data: (items) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(clientMessagesProvider);
                  await ref.read(clientMessagesProvider.future);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (items.isEmpty)
                      const Text(
                        'Send a message to start a conversation with Alpha.',
                      ),
                    for (final thread in items)
                      ListTile(
                        leading: const Icon(Icons.forum_outlined),
                        title: Text(thread.subject),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(
                          '/client/messages/thread/${thread.id}',
                          extra: thread,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Attach image, video or audio',
                    icon: const Icon(Icons.attach_file),
                    onPressed: sending
                        ? null
                        : () => pickMessageAttachment(context, (
                            file,
                            media,
                          ) async {
                            final user = ref.read(currentUserProvider);
                            if (user == null) return;
                            setState(() => sending = true);
                            try {
                              final repository = ref.read(
                                askAlphaRepositoryProvider,
                              );
                              final threads = await ref.read(
                                clientMessagesProvider.future,
                              );
                              final thread =
                                  threads
                                      .where((t) => t.orderId.isEmpty)
                                      .firstOrNull ??
                                  await repository.createClientConversation(
                                    user.id,
                                  );
                              await repository.sendAttachment(
                                thread.id,
                                user.id,
                                file,
                                media,
                              );
                              ref.invalidate(clientMessagesProvider);
                              if (mounted && context.mounted) {
                                context.push(
                                  '/client/messages/thread/${thread.id}',
                                  extra: thread,
                                );
                              }
                            } catch (e) {
                              if (mounted && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Unable to send attachment: $e',
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => sending = false);
                            }
                          }),
                  ),
                  Expanded(
                    child: TextField(
                      controller: message,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Message Alpha?',
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send message',
                    onPressed: sending ? null : _send,
                    icon: sending
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final text = message.text.trim();
    final user = ref.read(currentUserProvider);
    if (text.isEmpty || user == null) return;
    setState(() => sending = true);
    try {
      final repository = ref.read(askAlphaRepositoryProvider);
      final threads = await ref.read(clientMessagesProvider.future);
      final direct = threads
          .where((thread) => thread.orderId.isEmpty)
          .firstOrNull;
      final thread =
          direct ?? await repository.createClientConversation(user.id);
      await repository.sendMessage(thread.id, user.id, text);
      message.clear();
      ref.invalidate(clientMessagesProvider);
      if (mounted) {
        context.push('/client/messages/thread/${thread.id}', extra: thread);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to send message: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }
}
