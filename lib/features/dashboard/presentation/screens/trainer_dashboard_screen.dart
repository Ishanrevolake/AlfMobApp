import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';

class TrainerDashboardScreen extends ConsumerWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TRAINER DASHBOARD',
          style: TextStyle(fontFamily: 'AppSans'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'OVERVIEW',
              style: TextStyle(
                color: AppColors.mutedText,
                fontFamily: 'AppSans',
                fontSize: 12,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Trainer Dashboard.',
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(color: AppColors.primaryRed),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryPanel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.subtleBorder),
              ),
              child: Column(
                children: [
                  const Text(
                    'All Clients',
                    style: TextStyle(
                      fontFamily: 'AppSans',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/trainer/clients'),
                      child: const Text('MANAGE CLIENTS →'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
