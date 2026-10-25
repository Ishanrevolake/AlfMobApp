import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/alf_widgets.dart';
import '../controllers/workout_controller.dart';

class ClientWorkoutLibraryScreen extends ConsumerWidget {
  const ClientWorkoutLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(workoutControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const AlfBrand(compact: true)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(workoutControllerProvider);
          await ref.read(workoutControllerProvider.future);
        },
        child: plan.when(
          data: (value) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
            children: [
              AlfPageTitle(
                eyebrow: value?.focus ?? 'YOUR PROGRAMME',
                title: 'My programme',
                subtitle: 'Your complete plan from your coach.',
              ),
              const SizedBox(height: 24),
              if (value == null || value.days.isEmpty)
                const AlfEmptyState(
                  icon: Icons.fitness_center,
                  title: 'Your programme is being prepared',
                  message:
                      'Workout sessions will appear once your trainer assigns them.',
                )
              else
                ...value.days.map((day) {
                  final done = day.exercises.where((item) => item.done).length;
                  final complete =
                      day.exercises.isNotEmpty && done == day.exercises.length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () =>
                          context.push('/client/session/${day.dayOfWeek}'),
                      borderRadius: BorderRadius.circular(18),
                      child: Opacity(
                        opacity: day.rest ? .62 : 1,
                        child: AlfPanel(
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: day.rest
                                      ? AppColors.primaryPanel
                                      : AppColors.redTint,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  day.rest
                                      ? Icons.self_improvement
                                      : Icons.fitness_center,
                                  color: day.rest
                                      ? AppColors.faintText
                                      : AppColors.primaryRed,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${day.dayOfWeek} · ${day.title}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      day.rest
                                          ? 'Recovery day'
                                          : '${day.exercises.length} exercises · $done completed',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                    if (day.trainerNotes.trim().isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Session notes',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelSmall,
                                      ),
                                      Text(day.trainerNotes),
                                    ],
                                  ],
                                ),
                              ),
                              AlfStatusChip(
                                day.rest
                                    ? 'REST'
                                    : complete
                                    ? 'DONE'
                                    : 'READY',
                                positive: complete,
                                muted: day.rest,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
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
