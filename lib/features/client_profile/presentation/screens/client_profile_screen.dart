import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/profile_controller.dart';
import '../../../ask_alpha/presentation/controllers/ask_alpha_controller.dart';

class ClientProfileScreen extends ConsumerWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileStateAsync = ref.watch(profileControllerProvider);
    final askAlphaState = ref.watch(askAlphaControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ALFA LEE',
          style: TextStyle(fontFamily: 'AppSans', color: AppColors.primaryRed),
        ),
      ),
      body: profileStateAsync.when(
        data: (state) {
          final profile = state.profile;
          if (profile == null)
            return const Center(child: Text('Profile not found.'));

          final credits = askAlphaState?.credits ?? 0;
          final questionsAsked = askAlphaState?.orders.length ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPanel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.subtleBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.primaryRed, AppColors.deepRed],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            profile.initials,
                            style: const TextStyle(
                              fontFamily: 'AppSans',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.darkTextOverRed,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullName,
                              style: const TextStyle(
                                fontFamily: 'AppSans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'AlphaFitness · Coached by Alfa Lee',
                              style: TextStyle(
                                fontFamily: 'AppSans',
                                fontSize: 12,
                                color: AppColors.faintText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        title: '${profile.streak}',
                        subtitle: 'DAY STREAK',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBox(
                        title: '$credits',
                        subtitle: 'CREDITS LEFT',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBox(
                        title: '$questionsAsked',
                        subtitle: 'Q\'S ASKED',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontFamily: 'AppSans',
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPanel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.subtleBorder),
                  ),
                  child: Column(
                    children: [
                      _SettingsSwitchRow(
                        title: 'Session reminders',
                        icon: Icons.notifications_none,
                        value: state.notifSessionReminders,
                        onChanged: (val) => ref
                            .read(profileControllerProvider.notifier)
                            .toggleReminder(val),
                      ),
                      const Divider(),
                      _SettingsSwitchRow(
                        title: 'Ask Alpha reply alerts',
                        icon: Icons.chat_bubble_outline,
                        value: state.notifAskAlpha,
                        onChanged: (val) => ref
                            .read(profileControllerProvider.notifier)
                            .toggleAskAlphaAlert(val),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.credit_card,
                          color: AppColors.mutedText,
                        ),
                        title: const Text(
                          'Payment methods',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.faintText,
                        ),
                        contentPadding: EdgeInsets.zero,
                        onTap: () {},
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.help_outline,
                          color: AppColors.mutedText,
                        ),
                        title: const Text(
                          'Support',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.faintText,
                        ),
                        contentPadding: EdgeInsets.zero,
                        onTap: () {},
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: AppColors.primaryRed,
                        ),
                        title: const Text(
                          'Log out',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryRed,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
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
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StatBox({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryPanel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'AppSans',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'AppSans',
              fontSize: 12,
              letterSpacing: 0.5,
              color: AppColors.faintText,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchRow({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.mutedText),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primaryRed,
        activeTrackColor: AppColors.redTint,
        inactiveThumbColor: AppColors.faintText,
        inactiveTrackColor: AppColors.secondaryPanel,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
