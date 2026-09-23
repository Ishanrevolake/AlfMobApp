export 'trainer_programs_page.dart';
export 'trainer_library_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/alf_widgets.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../client_profile/data/models/profile_models.dart';
import '../data/trainer_repository.dart';

final trainerClientsProvider = FutureProvider.autoDispose<List<ClientProfile>>(
  (ref) => ref.watch(trainerRepositoryProvider).getClients(),
);
final trainerPaymentsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => ref
          .watch(trainerRepositoryProvider)
          .getRows('payments', orderBy: 'created_at'),
    );
final trainerAskOrdersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => ref
          .watch(trainerRepositoryProvider)
          .getRows('ask_alpha_orders', orderBy: 'submitted_at'),
    );
final trainerThreadsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => ref
          .watch(trainerRepositoryProvider)
          .getRows('ask_alpha_threads', orderBy: 'updated_at'),
    );

class TrainerOverviewPage extends ConsumerWidget {
  const TrainerOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(trainerClientsProvider);
    final payments = ref.watch(trainerPaymentsProvider);
    final threads = ref.watch(trainerThreadsProvider);
    final user = ref.watch(currentUserProvider);
    final name =
        (user?.userMetadata?['name'] ??
                user?.userMetadata?['full_name'] ??
                'Trainer')
            .toString();
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(trainerClientsProvider);
        ref.invalidate(trainerPaymentsProvider);
        ref.invalidate(trainerThreadsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
        children: [
          AlfPageTitle(
            eyebrow: DateFormat('EEEE · MMM d').format(DateTime.now()),
            title: 'Welcome, ${name.split(' ').first}',
            subtitle: 'Your coaching business at a glance.',
          ),
          const SizedBox(height: 26),
          AlfResponsiveGrid(
            minItemWidth: 155,
            maxColumns: 4,
            spacing: 12,
            children: [
              AlfStatTile(
                value: clients.when(
                  data: (v) =>
                      '${v.where((c) => c.status != 'inactive').length}',
                  loading: () => '—',
                  error: (_, __) => '—',
                ),
                label: 'Active clients',
                icon: Icons.groups_2_outlined,
              ),
              AlfStatTile(
                value: payments.when(
                  data: (v) =>
                      '${v.where((p) => _text(p, ['status']) != 'verified').length}',
                  loading: () => '—',
                  error: (_, __) => '—',
                ),
                label: 'Payments pending',
                icon: Icons.receipt_long_outlined,
              ),
              AlfStatTile(
                value: threads.when(
                  data: (v) =>
                      '${v.where((t) => _text(t, ['status']) == 'open').length}',
                  loading: () => '—',
                  error: (_, __) => '—',
                ),
                label: 'Open questions',
                icon: Icons.forum_outlined,
              ),
              AlfStatTile(
                value: clients.when(
                  data: (v) =>
                      '${v.where((c) => c.daysLeft > 0 && c.daysLeft <= 7).length}',
                  loading: () => '—',
                  error: (_, __) => '—',
                ),
                label: 'Renewals soon',
                icon: Icons.autorenew,
              ),
            ],
          ),
          const SizedBox(height: 28),
          AlfSectionHeader(title: 'Quick actions'),
          AlfPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ActionRow(
                  icon: Icons.person_add_alt_1,
                  title: 'Manage clients',
                  subtitle: 'Profiles, workouts, meals and notes',
                  onTap: () => context.go('/trainer/clients'),
                ),
                const Divider(),
                _ActionRow(
                  icon: Icons.fitness_center,
                  title: 'Packages',
                  subtitle: 'Review packages assigned to clients',
                  onTap: () => context.go('/trainer/programs'),
                ),
                const Divider(),
                _ActionRow(
                  icon: Icons.mark_email_unread_outlined,
                  title: 'Ask Alpha inbox',
                  subtitle: 'Reply to paid client questions',
                  onTap: () => context.push('/trainer/ask-inbox'),
                ),
                const Divider(),
                _ActionRow(
                  icon: Icons.verified_outlined,
                  title: 'Verify payments',
                  subtitle: 'Review new payment slips',
                  onTap: () => context.push('/trainer/payments'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          AlfSectionHeader(
            title: 'Recent clients',
            actionLabel: 'SEE ALL',
            onAction: () => context.go('/trainer/clients'),
          ),
          clients.when(
            data: (items) => AlfPanel(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: items.isEmpty
                  ? const AlfEmptyState(
                      icon: Icons.group_off_outlined,
                      title: 'No clients yet',
                      message: 'Client profiles will appear here.',
                    )
                  : Column(
                      children: items
                          .take(4)
                          .map((client) => _ClientRow(client: client))
                          .toList(),
                    ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AlfAsyncError(error: error),
          ),
        ],
      ),
    );
  }
}

class TrainerClientsPage extends ConsumerStatefulWidget {
  const TrainerClientsPage({super.key});
  @override
  ConsumerState<TrainerClientsPage> createState() => _TrainerClientsPageState();
}

class _TrainerClientsPageState extends ConsumerState<TrainerClientsPage> {
  String search = '';
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(trainerClientsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(trainerClientsProvider),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
        children: [
          const AlfPageTitle(
            eyebrow: 'Coaching roster',
            title: 'Clients',
            subtitle: 'Manage profiles, progress and assigned plans.',
          ),
          const SizedBox(height: 22),
          TextField(
            onChanged: (value) =>
                setState(() => search = value.trim().toLowerCase()),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search clients…',
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('All')),
              ButtonSegment(value: 'active', label: Text('Active')),
              ButtonSegment(value: 'inactive', label: Text('Inactive')),
            ],
            selected: {filter},
            onSelectionChanged: (value) => setState(() => filter = value.first),
          ),
          const SizedBox(height: 20),
          clients.when(
            data: (items) {
              final visible = items.where((client) {
                final matchesSearch =
                    search.isEmpty ||
                    client.fullName.toLowerCase().contains(search) ||
                    client.email.toLowerCase().contains(search);
                final matchesFilter =
                    filter == 'all' || client.status == filter;
                return matchesSearch && matchesFilter;
              }).toList();
              if (visible.isEmpty) {
                return const AlfEmptyState(
                  icon: Icons.person_search_outlined,
                  title: 'No matching clients',
                  message: 'Try a different search or status filter.',
                );
              }
              return AlfPanel(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: visible
                      .map((client) => _ClientRow(client: client))
                      .toList(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AlfAsyncError(error: error),
          ),
        ],
      ),
    );
  }
}

class TrainerMorePage extends StatelessWidget {
  const TrainerMorePage({super.key});
  @override
  Widget build(BuildContext context) {
    final sections = <(IconData, String, String, String)>[
      (
        Icons.receipt_long_outlined,
        'Payment verification',
        'Review coaching payments',
        '/trainer/payments',
      ),
      (
        Icons.credit_score_outlined,
        'Ask Alpha payments',
        'Approve question credits',
        '/trainer/ask-payments',
      ),
      (
        Icons.mark_email_unread_outlined,
        'Ask Alpha inbox',
        'Reply to client questions',
        '/trainer/ask-inbox',
      ),
      (
        Icons.analytics_outlined,
        'Analytics',
        'Growth and performance',
        '/trainer/section/analytics',
      ),
      (
        Icons.phone_in_talk_outlined,
        'Leads',
        'Enquiry pipeline',
        '/trainer/section/leads',
      ),
      (
        Icons.article_outlined,
        'Blog',
        'Education content',
        '/trainer/section/blog',
      ),
      (
        Icons.star_outline,
        'Testimonials',
        'Client transformation stories',
        '/trainer/section/testimonials',
      ),
      (
        Icons.menu_book_outlined,
        'Recipes',
        'Nutrition resources',
        '/trainer/section/recipes',
      ),
      (
        Icons.play_circle_outline,
        'Social & media',
        'Content planner',
        '/trainer/section/social',
      ),
      (
        Icons.notifications_none,
        'Notifications',
        'Renewals and milestones',
        '/trainer/section/notifications',
      ),
      (
        Icons.settings_outlined,
        'Settings',
        'Account and application',
        '/trainer/section/settings',
      ),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        const AlfPageTitle(
          eyebrow: 'Business tools',
          title: 'More',
          subtitle: 'The complete trainer workspace.',
        ),
        const SizedBox(height: 24),
        AlfPanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < sections.length; i++) ...[
                _ActionRow(
                  icon: sections[i].$1,
                  title: sections[i].$2,
                  subtitle: sections[i].$3,
                  onTap: () => context.push(sections[i].$4),
                ),
                if (i != sections.length - 1) const Divider(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class TrainerPaymentsScreen extends ConsumerWidget {
  final bool askAlpha;
  const TrainerPaymentsScreen({super.key, this.askAlpha = false});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = askAlpha
        ? trainerAskOrdersProvider
        : trainerPaymentsProvider;
    final rows = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(
        title: Text(askAlpha ? 'ASK ALPHA PAYMENTS' : 'PAYMENT VERIFICATION'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(provider),
        child: rows.when(
          data: (items) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AlfPageTitle(
                eyebrow: 'Business',
                title: askAlpha ? 'Question credits' : 'Payment slips',
                subtitle:
                    'Review submissions and mark approved payments as verified.',
              ),
              const SizedBox(height: 24),
              if (items.isEmpty)
                const AlfEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No payments found',
                  message: 'New submissions will appear here.',
                ),
              ...items.map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AlfPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _text(
                                  row,
                                  askAlpha
                                      ? ['product_title']
                                      : [
                                          'package_name',
                                          'product_title',
                                          'title',
                                        ],
                                  fallback: 'Payment',
                                ),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            AlfStatusChip(
                              _text(row, ['status'], fallback: 'pending'),
                              positive: _text(row, ['status']) == 'verified',
                              muted: _text(row, ['status']) == 'rejected',
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Text(
                          askAlpha
                              ? 'LKR ${_text(row, ['amount_lkr'], fallback: '0')} · ${_text(row, ['question_credits'], fallback: '0')} credits'
                              : 'LKR ${_text(row, ['amount', 'amount_lkr', 'total'], fallback: '—')}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 14),
                        if (_text(row, ['status']) != 'verified')
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _verify(context, ref, row),
                                  icon: const Icon(Icons.check, size: 17),
                                  label: const Text('VERIFY'),
                                ),
                              ),
                              if (askAlpha) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _reject(context, ref, row),
                                    child: const Text('REJECT'),
                                  ),
                                ),
                              ],
                            ],
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

  Future<void> _verify(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> row,
  ) async {
    try {
      final repo = ref.read(trainerRepositoryProvider);
      final userId = ref.read(currentUserProvider)?.id ?? '';
      if (askAlpha) {
        await repo.verifyAskOrder(row['id'].toString(), userId);
      } else {
        await repo.verifyPayment(row['id'].toString(), userId);
      }
      ref.invalidate(
        askAlpha ? trainerAskOrdersProvider : trainerPaymentsProvider,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment verified.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _reject(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> row,
  ) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject payment'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('REJECT'),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;
    try {
      await ref
          .read(trainerRepositoryProvider)
          .rejectAskOrder(row['id'].toString(), reason);
      ref.invalidate(trainerAskOrdersProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class TrainerAskInboxScreen extends ConsumerWidget {
  const TrainerAskInboxScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(trainerThreadsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('ASK ALPHA INBOX')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(trainerThreadsProvider),
        child: threads.when(
          data: (items) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const AlfPageTitle(
                eyebrow: 'Direct coaching',
                title: 'Inbox',
                subtitle: 'Answer paid questions and form reviews.',
              ),
              const SizedBox(height: 24),
              if (items.isEmpty)
                const AlfEmptyState(
                  icon: Icons.forum_outlined,
                  title: 'Inbox is clear',
                  message: 'Client questions will appear here.',
                ),
              ...items.map(
                (thread) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => context.push(
                      '/trainer/ask-inbox/${thread['id']}',
                      extra: thread,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    child: AlfPanel(
                      child: Row(
                        children: [
                          const AlfAvatar(initials: 'Q'),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _text(thread, [
                                    'subject',
                                  ], fallback: 'Ask Alpha question'),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _formatDate(thread['updated_at']),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          AlfStatusChip(
                            _text(thread, ['status'], fallback: 'open'),
                            positive: _text(thread, ['status']) == 'answered',
                            muted: _text(thread, ['status']) == 'closed',
                          ),
                        ],
                      ),
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
}

class TrainerThreadScreen extends ConsumerStatefulWidget {
  final String threadId;
  final Map<String, dynamic>? thread;
  const TrainerThreadScreen({super.key, required this.threadId, this.thread});
  @override
  ConsumerState<TrainerThreadScreen> createState() =>
      _TrainerThreadScreenState();
}

class _TrainerThreadScreenState extends ConsumerState<TrainerThreadScreen> {
  final reply = TextEditingController();
  bool sending = false;
  @override
  void dispose() {
    reply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(_threadMessagesProvider(widget.threadId));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text(widget.thread ?? {}, ['subject'], fallback: 'ASK ALPHA'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data: (items) => ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final message = items[index];
                  final mine = _text(message, ['sender_role']) != 'client';
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_text(message, ['body', 'content'])),
                          const SizedBox(height: 5),
                          Text(
                            _formatDate(message['created_at']),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AlfAsyncError(error: error),
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
                      controller: reply,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Write a reply…',
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
    if (reply.text.trim().isEmpty) return;
    setState(() => sending = true);
    try {
      final user = ref.read(currentUserProvider);
      final role = await ref.read(userRoleProvider.future);
      await ref
          .read(trainerRepositoryProvider)
          .replyToThread(
            threadId: widget.threadId,
            trainerId: user?.id ?? '',
            role: role,
            body: reply.text,
          );
      reply.clear();
      ref.invalidate(_threadMessagesProvider(widget.threadId));
      ref.invalidate(trainerThreadsProvider);
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

class TrainerSectionScreen extends ConsumerWidget {
  final String section;
  const TrainerSectionScreen({super.key, required this.section});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (section == 'settings') return _SettingsBody(ref: ref);
    final config = _sectionConfigs[section] ?? _sectionConfigs['analytics']!;
    final rows = config.table == null
        ? null
        : ref.watch(
            _rowsProvider(_TableRequest(config.table!, config.orderBy)),
          );
    return Scaffold(
      appBar: AppBar(title: Text(config.title.toUpperCase())),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AlfPageTitle(
            eyebrow: config.eyebrow,
            title: config.title,
            subtitle: config.subtitle,
          ),
          const SizedBox(height: 24),
          if (rows == null)
            ...config.samples.map(
              (sample) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AlfPanel(
                  child: Row(
                    children: [
                      Icon(config.icon, color: AppColors.primaryRed),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sample.$1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sample.$2,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      AlfStatusChip(sample.$3, muted: true),
                    ],
                  ),
                ),
              ),
            )
          else
            rows.when(
              data: (items) => items.isEmpty
                  ? AlfEmptyState(
                      icon: config.icon,
                      title: 'No ${config.title.toLowerCase()} found',
                      message:
                          'Records from the web application will appear here.',
                    )
                  : Column(
                      children: items
                          .map(
                            (row) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: AlfPanel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _text(
                                        row,
                                        config.titleFields,
                                        fallback: config.title,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _text(
                                        row,
                                        config.detailFields,
                                        fallback: _formatDate(
                                          row['created_at'],
                                        ),
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    if (_text(row, ['status']).isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      AlfStatusChip(
                                        _text(row, ['status']),
                                        positive:
                                            _text(row, ['status']) ==
                                                'published' ||
                                            _text(row, ['status']) ==
                                                'approved',
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AlfAsyncError(error: error),
            ),
        ],
      ),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  final WidgetRef ref;
  const _SettingsBody({required this.ref});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SETTINGS')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const AlfPageTitle(
          eyebrow: 'Account',
          title: 'Settings',
          subtitle: 'Trainer access and application preferences.',
        ),
        const SizedBox(height: 24),
        AlfPanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _ActionRow(
                icon: Icons.person_outline,
                title: 'Signed-in account',
                subtitle: ref.watch(currentUserProvider)?.email ?? '',
                onTap: () {},
              ),
              const Divider(),
              _ActionRow(
                icon: Icons.logout,
                title: 'Log out',
                subtitle: 'End this session on this device',
                danger: true,
                onTap: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ClientRow extends StatelessWidget {
  final ClientProfile client;
  const _ClientRow({required this.client});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.push('/trainer/client/${client.id}', extra: client),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          AlfAvatar(initials: client.initials),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  client.email.isEmpty ? client.goal : client.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          AlfStatusChip(
            client.status,
            positive: client.status == 'active',
            muted: client.status == 'inactive',
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.faintText),
        ],
      ),
    ),
  );
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    leading: Icon(
      icon,
      color: danger ? AppColors.primaryRed : AppColors.mutedText,
    ),
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: danger ? AppColors.primaryRed : null,
      ),
    ),
    subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    trailing: const Icon(Icons.chevron_right, color: AppColors.faintText),
  );
}

class _TableRequest {
  final String table;
  final String? orderBy;
  final bool ascending;
  const _TableRequest(this.table, [this.orderBy]) : ascending = false;
  @override
  bool operator ==(Object other) =>
      other is _TableRequest &&
      other.table == table &&
      other.orderBy == orderBy &&
      other.ascending == ascending;
  @override
  int get hashCode => Object.hash(table, orderBy, ascending);
}

final _rowsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, _TableRequest>(
      (ref, request) => ref
          .watch(trainerRepositoryProvider)
          .getRows(
            request.table,
            orderBy: request.orderBy,
            ascending: request.ascending,
          ),
    );
final _threadMessagesProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>(
      (ref, threadId) async => List<Map<String, dynamic>>.from(
        await ref
            .watch(supabaseProvider)
            .from('ask_alpha_messages')
            .select()
            .eq('thread_id', threadId)
            .order('created_at'),
      ),
    );

String _text(
  Map<String, dynamic> row,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = row[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return fallback;
}

String _formatDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  return date == null
      ? ''
      : DateFormat('MMM d, yyyy · h:mm a').format(date.toLocal());
}

class _SectionConfig {
  final String title, eyebrow, subtitle;
  final IconData icon;
  final String? table, orderBy;
  final List<String> titleFields, detailFields;
  final List<(String, String, String)> samples;
  const _SectionConfig({
    required this.title,
    required this.eyebrow,
    required this.subtitle,
    required this.icon,
    this.table,
    this.orderBy,
    this.titleFields = const ['name', 'title'],
    this.detailFields = const ['description', 'excerpt', 'email'],
    this.samples = const [],
  });
}

const _sectionConfigs = <String, _SectionConfig>{
  'analytics': _SectionConfig(
    title: 'Analytics',
    eyebrow: 'Performance',
    subtitle: 'Track client growth and programme coverage.',
    icon: Icons.analytics_outlined,
    table: 'analytics_events',
    orderBy: 'created_at',
    titleFields: ['event_name', 'event_type', 'name'],
    detailFields: ['path', 'page', 'route'],
  ),
  'leads': _SectionConfig(
    title: 'Leads',
    eyebrow: 'Pipeline',
    subtitle: 'Review new enquiries and follow-up priorities.',
    icon: Icons.phone_in_talk_outlined,
    table: 'leads',
    orderBy: 'created_at',
    titleFields: ['full_name', 'name', 'email'],
    detailFields: ['message', 'goal', 'phone'],
  ),
  'blog': _SectionConfig(
    title: 'Blog',
    eyebrow: 'Content',
    subtitle: 'Education articles shared by the web application.',
    icon: Icons.article_outlined,
    table: 'blog_posts',
    orderBy: 'updated_at',
    titleFields: ['title'],
    detailFields: ['excerpt', 'content'],
  ),
  'testimonials': _SectionConfig(
    title: 'Testimonials',
    eyebrow: 'Social proof',
    subtitle: 'Client transformation stories and reviews.',
    icon: Icons.star_outline,
    table: 'testimonials',
    orderBy: 'created_at',
    titleFields: ['name'],
    detailFields: ['text', 'category'],
  ),
  'recipes': _SectionConfig(
    title: 'Recipes',
    eyebrow: 'Nutrition content',
    subtitle: 'Recipe book and downloadable resources.',
    icon: Icons.menu_book_outlined,
    samples: [
      ('High Protein Sri Lankan Breakfasts', 'Breakfast · 12 recipes', 'LIVE'),
      ('Lean Dinner Pack', 'Dinner · Fat loss', 'REVIEW'),
      ('Muscle Gain Rice Bowls', 'Bulking · Local foods', 'LIVE'),
    ],
  ),
  'social': _SectionConfig(
    title: 'Social & media',
    eyebrow: 'Channels',
    subtitle: 'Organize media and the content pipeline.',
    icon: Icons.play_circle_outline,
    samples: [
      ('YouTube', '@AlphaLeeFitness · Long-form video', 'ACTIVE'),
      ('Instagram', '@lalitha_epaarachchi · Reels and stories', 'ACTIVE'),
      ('Facebook', 'alphaleefitness · Community posts', 'ACTIVE'),
    ],
  ),
  'notifications': _SectionConfig(
    title: 'Notifications',
    eyebrow: 'Alerts',
    subtitle: 'Renewals, new leads and client milestones.',
    icon: Icons.notifications_none,
    samples: [
      ('Renewal reminder', 'A client programme ends soon.', 'URGENT'),
      ('New enquiry', 'A new coaching lead needs a reply.', 'NEW'),
      ('Client milestone', 'A coaching milestone was completed.', 'MILESTONE'),
    ],
  ),
};
