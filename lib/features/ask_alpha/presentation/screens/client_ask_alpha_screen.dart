import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/alf_widgets.dart';
import '../controllers/ask_alpha_controller.dart';

class ClientAskAlphaScreen extends ConsumerWidget {
  const ClientAskAlphaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(askAlphaControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const AlfBrand(compact: true)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(askAlphaControllerProvider),
        child: state.when(
          data: (value) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            children: [
              const AlfPageTitle(
                eyebrow: 'Your coach · direct line',
                title: 'Ask Alpha',
                subtitle:
                    'Submit a paid question or form review. Your coach replies in the app.',
              ),
              const SizedBox(height: 24),
              AlfPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AlfStatusChip(
                      '${value.credits} CREDITS LEFT',
                      positive: true,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Direct coaching access',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Credits become available after your payment slip is verified.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 17),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showCreditSheet(context, ref),
                            child: const Text('BUY CREDITS'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: value.credits > 0
                                ? () => context.push('/client/ask-alpha/new')
                                : null,
                            child: const Text('ASK QUESTION'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const AlfSectionHeader(title: 'Conversations'),
              if (value.threads.isEmpty)
                const AlfEmptyState(
                  icon: Icons.forum_outlined,
                  title: 'No conversations yet',
                  message: 'Your coach replies will appear here.',
                ),
              ...value.threads.map(
                (thread) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => context.push(
                      '/client/ask-alpha/thread/${thread.id}',
                      extra: thread,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    child: AlfPanel(
                      child: Row(
                        children: [
                          const AlfAvatar(initials: 'A'),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  thread.subject,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  DateFormat(
                                    'MMM d · h:mm a',
                                  ).format(thread.updatedAt.toLocal()),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          AlfStatusChip(
                            thread.status,
                            positive: thread.status == 'answered',
                            muted: thread.status == 'closed',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const AlfSectionHeader(title: 'Order history'),
              if (value.orders.isEmpty)
                const AlfEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No credit orders',
                  message: 'Purchase a credit pack to start a conversation.',
                ),
              ...value.orders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AlfPanel(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${order.credits} credits · LKR ${order.amount} · ${order.meta}',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        AlfStatusChip(
                          order.status,
                          positive: order.status == 'verified',
                          muted: order.status == 'rejected',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              ListView(children: [AlfAsyncError(error: error)]),
        ),
      ),
    );
  }

  Future<void> _showCreditSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) =>
          const SingleChildScrollView(child: _BuyCreditsSheet()),
    );
  }
}

class _BuyCreditsSheet extends ConsumerStatefulWidget {
  const _BuyCreditsSheet();
  @override
  ConsumerState<_BuyCreditsSheet> createState() => _BuyCreditsSheetState();
}

class _BuyCreditsSheetState extends ConsumerState<_BuyCreditsSheet> {
  int selected = 0;
  File? slip;
  bool saving = false;
  final packs = const [
    ('single', 'Single question', 1, 2500),
    ('three-pack', '3-question pack', 3, 6500),
    ('five-pack', '5-question pack', 5, 9500),
  ];

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      22,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('BUY CREDITS', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 5),
        Text(
          'Choose a pack and attach your bank payment slip.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < packs.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: InkWell(
              onTap: () => setState(() => selected = i),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected == i ? AppColors.redTint : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected == i
                        ? AppColors.primaryRed
                        : AppColors.strongBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected == i
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected == i
                          ? AppColors.primaryRed
                          : AppColors.faintText,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        packs[i].$2,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      'LKR ${packs[i].$4}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final image = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              imageQuality: 85,
            );
            if (image != null) setState(() => slip = File(image.path));
          },
          icon: Icon(
            slip == null ? Icons.upload_file : Icons.check_circle,
            color: slip == null ? null : AppColors.primaryRed,
          ),
          label: Text(
            slip == null ? 'ATTACH PAYMENT SLIP' : 'PAYMENT SLIP ATTACHED',
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: saving || slip == null ? null : _submit,
          child: saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('SUBMIT FOR VERIFICATION'),
        ),
      ],
    ),
  );

  Future<void> _submit() async {
    setState(() => saving = true);
    try {
      final pack = packs[selected];
      await ref
          .read(askAlphaControllerProvider.notifier)
          .buyCredits(pack.$1, pack.$2, pack.$3, pack.$4, slip);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}
