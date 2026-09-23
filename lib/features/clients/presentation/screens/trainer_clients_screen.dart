import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/clients_controller.dart';

class TrainerClientsScreen extends ConsumerWidget {
  const TrainerClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsState = ref.watch(clientsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ALL CLIENTS',
          style: TextStyle(fontFamily: 'AppSans', color: AppColors.primaryRed),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () => context.pop(),
        ),
      ),
      body: clientsState.when(
        data: (clients) {
          if (clients.isEmpty)
            return const Center(child: Text('No clients found.'));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryPanel,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.subtleBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryPanel,
                      ),
                      child: Center(
                        child: Text(
                          client.fullName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'AppSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primaryRed,
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
                            client.fullName,
                            style: const TextStyle(
                              fontFamily: 'AppSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            client.email,
                            style: const TextStyle(
                              fontFamily: 'AppSans',
                              fontSize: 12,
                              color: AppColors.faintText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: AppColors.faintText,
                      ),
                      onPressed: () {
                        // Open client detail
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
