import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'message_attachment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/ask_alpha_models.dart';
import '../../data/repositories/ask_alpha_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/message_unread_controller.dart';

class ClientThreadScreen extends ConsumerStatefulWidget {
  final String threadId;
  final AskAlphaThread? thread;
  const ClientThreadScreen({super.key, required this.threadId, this.thread});
  @override
  ConsumerState<ClientThreadScreen> createState() => _ClientThreadScreenState();
}

class _ClientThreadScreenState extends ConsumerState<ClientThreadScreen> {
  final message = TextEditingController();
  bool sending = false;
  String? lastReadMessage;
  late final Stream<List<AskAlphaMessage>> messages = ref
      .read(askAlphaRepositoryProvider)
      .messagesStream(widget.threadId);
  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.thread?.subject ?? 'MESSAGES').toUpperCase()),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<AskAlphaMessage>>(
              stream: messages,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Unable to load messages: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!;
                final incoming = items.where(
                  (item) => item.senderRole != 'client',
                );
                if (incoming.isNotEmpty &&
                    lastReadMessage != incoming.last.id) {
                  final latestId = incoming.last.id;
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (!mounted || ModalRoute.of(context)?.isCurrent != true) {
                      return;
                    }
                    final userId = ref.read(currentUserProvider)?.id;
                    if (userId == null) return;
                    try {
                      await markTrainerMessagesRead(
                        userId,
                        widget.threadId,
                        items,
                      );
                      if (!mounted) return;
                      lastReadMessage = latestId;
                      ref.invalidate(unreadTrainerMessagesProvider);
                    } catch (_) {
                      // Keep the unread indicator if local read status cannot be saved.
                    }
                  });
                }
                if (items.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final mine = item.senderRole == 'client';
                    return Align(
                      alignment: mine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(13),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * .78,
                        ),
                        decoration: BoxDecoration(
                          color: mine
                              ? AppColors.redTint
                              : AppColors.primaryPanel,
                          border: Border.all(
                            color: mine
                                ? AppColors.redBorder
                                : AppColors.subtleBorder,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MessageAttachment(body: item.content),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat(
                                'EEE, d MMM yyyy ? HH:mm',
                              ).format(item.createdAt.toLocal()),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
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
                              await ref
                                  .read(askAlphaRepositoryProvider)
                                  .sendAttachment(
                                    widget.threadId,
                                    user.id,
                                    file,
                                    media,
                                  );
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
                        hintText: 'Reply to your coach…',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: sending ? null : _send,
                    icon: sending
                        ? const SizedBox.square(
                            dimension: 18,
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
    if (message.text.trim().isEmpty) return;
    setState(() => sending = true);
    try {
      await ref
          .read(askAlphaRepositoryProvider)
          .sendMessage(
            widget.threadId,
            ref.read(currentUserProvider)?.id ?? '',
            message.text.trim(),
          );
      message.clear();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }
}
