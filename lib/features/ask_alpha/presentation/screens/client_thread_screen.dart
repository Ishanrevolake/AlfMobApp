import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/ask_alpha_models.dart';
import '../../data/repositories/ask_alpha_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

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
  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(askAlphaRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.thread?.subject ?? 'ASK ALPHA').toUpperCase()),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<AskAlphaMessage>>(
              stream: repository.messagesStream(widget.threadId),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final items = snapshot.data!;
                if (items.isEmpty)
                  return const Center(child: Text('No messages yet.'));
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
                        child: Text(item.content),
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
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }
}
