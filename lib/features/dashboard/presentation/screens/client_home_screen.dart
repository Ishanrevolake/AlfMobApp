import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/alf_widgets.dart';
import '../../../ask_alpha/presentation/controllers/ask_alpha_controller.dart';
import '../../../client_profile/presentation/controllers/profile_controller.dart';
import '../../../meal_plans/presentation/controllers/meal_controller.dart';
import '../../../workouts/data/models/workout_models.dart';
import '../../../workouts/presentation/controllers/workout_controller.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutControllerProvider);
    final meals = ref.watch(mealControllerProvider);
    final ask = ref.watch(askAlphaControllerProvider);
    final profile = ref.watch(profileControllerProvider);
    final now = DateTime.now();
    final dayCode = DateFormat('EEE').format(now).toUpperCase();
    final name = profile.value?.profile?.fullName.split(' ').first ?? 'Athlete';
    final plan = workout.value;
    final today = plan == null ? null : _findDay(plan.days, dayCode);
    final done =
        today?.exercises.where((exercise) => exercise.done).length ?? 0;
    final total = today?.exercises.length ?? 0;
    final credits = ask.value?.credits ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const AlfBrand(compact: true),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/client/ask-alpha'),
            icon: const Icon(
              Icons.circle,
              size: 7,
              color: AppColors.primaryRed,
            ),
            label: Text(
              'ASK ALPHA  $credits',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.primaryText),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(workoutControllerProvider);
          ref.invalidate(mealControllerProvider);
          ref.invalidate(askAlphaControllerProvider);
          ref.invalidate(profileControllerProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          children: [
            AlfPageTitle(
              eyebrow:
                  '${DateFormat('EEEE · MMM d').format(now)} · ${plan?.focus ?? 'YOUR PLAN'}',
              title: 'Good morning,\n$name',
            ),
            const SizedBox(height: 26),
            workout.when(
              data: (_) => AlfPanel(
                color: AppColors.secondaryPanel,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                today?.rest == true
                                    ? 'REST DAY'
                                    : '$dayCode · TODAY\'S SESSION',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: AppColors.primaryRed),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                today?.title ??
                                    (plan == null
                                        ? 'Programme pending'
                                        : 'Recovery day'),
                                style: Theme.of(
                                  context,
                                ).textTheme.displayMedium,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                today?.meta ??
                                    (plan?.trainerNotes.isNotEmpty == true
                                        ? plan!.trainerNotes
                                        : 'Your coach is preparing your next session.'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (total > 0)
                          SizedBox.square(
                            dimension: 62,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: done / total,
                                  strokeWidth: 5,
                                  backgroundColor: AppColors.primaryPanel,
                                  color: AppColors.primaryRed,
                                ),
                                Text(
                                  '$done/$total',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(color: AppColors.primaryText),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: today == null || today.rest
                            ? null
                            : () => context.push(
                                '/client/session/${today.dayOfWeek}',
                              ),
                        child: Text(
                          today?.rest == true
                              ? 'REST DAY — RECOVER'
                              : total > 0 && done == total
                              ? 'REVIEW SESSION →'
                              : 'START SESSION →',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const AlfPanel(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => AlfAsyncError(error: error),
            ),
            const SizedBox(height: 26),
            AlfSectionHeader(
              title: 'Your questions',
              actionLabel: 'OPEN',
              onAction: () => context.go('/client/ask-alpha'),
            ),
            AlfPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AlfStatusChip('$credits CREDITS LEFT', positive: true),
                  const SizedBox(height: 12),
                  Text(
                    'Ask Alpha',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Direct Q&A with your coach — text or form review.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (ask.value?.threads.isNotEmpty == true) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundBlack,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.subtleBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              ask.value!.threads.first.subject,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AlfStatusChip(
                            ask.value!.threads.first.status,
                            positive:
                                ask.value!.threads.first.status == 'answered',
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go('/client/ask-alpha'),
                          child: const Text('VIEW HISTORY'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: credits > 0
                              ? () => context.push('/client/ask-alpha/new')
                              : () => context.go('/client/ask-alpha'),
                          child: Text(
                            credits > 0 ? 'ASK QUESTION' : 'BUY CREDITS',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            AlfSectionHeader(
              title: 'This week\'s programme',
              actionLabel: 'FULL PLAN',
              onAction: () => context.go('/client/train'),
            ),
            SizedBox(
              height: 66,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: plan?.days.length ?? 0,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final day = plan!.days[index];
                  final selected = day.dayOfWeek == dayCode;
                  return InkWell(
                    onTap: day.rest
                        ? null
                        : () =>
                              context.push('/client/session/${day.dayOfWeek}'),
                    child: Container(
                      width: 52,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryRed
                            : day.exercises.every((e) => e.done) &&
                                  day.exercises.isNotEmpty
                            ? AppColors.redTint
                            : AppColors.primaryPanel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryRed
                              : AppColors.subtleBorder,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.dayOfWeek,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: selected
                                      ? AppColors.darkTextOverRed
                                      : null,
                                ),
                          ),
                          const SizedBox(height: 7),
                          Icon(
                            day.rest
                                ? Icons.remove
                                : day.exercises.every((e) => e.done) &&
                                      day.exercises.isNotEmpty
                                ? Icons.check
                                : Icons.circle,
                            size: selected ? 9 : 14,
                            color: selected
                                ? AppColors.darkTextOverRed
                                : AppColors.primaryRed,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 26),
            AlfSectionHeader(
              title: 'Today\'s meal plan',
              actionLabel: 'SEE ALL',
              onAction: () => context.go('/client/meals'),
            ),
            meals.when(
              data: (mealPlan) {
                final day = mealPlan == null
                    ? null
                    : mealPlan.days
                          .where((item) => item.dayOfWeek == dayCode)
                          .firstOrNull;
                final meal = day?.meals.firstOrNull;
                if (meal == null)
                  return const AlfPanel(
                    child: Text('No meals scheduled for today.'),
                  );
                return AlfPanel(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: AppColors.darkTextOverRed,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${meal.kcal} kcal · ${meal.protein}g protein · ${meal.time}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        meal.eaten ? Icons.check_circle : Icons.circle_outlined,
                        color: meal.eaten
                            ? AppColors.primaryRed
                            : AppColors.faintText,
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AlfAsyncError(error: error),
            ),
          ],
        ),
      ),
    );
  }

  WorkoutDay? _findDay(List<WorkoutDay> days, String code) =>
      days.where((day) => day.dayOfWeek == code).firstOrNull ??
      days.where((day) => !day.rest && day.exercises.isNotEmpty).firstOrNull;
}
