import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/alf_widgets.dart';
import '../../../../shared/plan_days.dart';
import '../widgets/weekly_programme_strip.dart';
import '../../../client_profile/presentation/controllers/profile_controller.dart';
import '../../../meal_plans/presentation/controllers/meal_controller.dart';
import '../../../meal_plans/presentation/widgets/home_meal_grid.dart';
import '../../../workouts/data/models/workout_models.dart';
import '../../../workouts/presentation/controllers/workout_controller.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  DateTime selectedDate = DateUtils.dateOnly(DateTime.now());

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 5, 12, 31),
    );
    if (date != null && mounted) {
      setState(() => selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(workoutControllerProvider);
    final meals = ref.watch(mealControllerProvider);
    final profile = ref.watch(profileControllerProvider);
    final now = selectedDate;
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());
    final dayCode = DateFormat('EEE').format(now).toUpperCase();
    final name = profile.value?.profile?.fullName.split(' ').first ?? 'Athlete';
    final plan = workout.value;
    final today =
        plan == null ||
            selectedDate.isBefore(DateUtils.dateOnly(plan.startDate))
        ? null
        : _findDay(plan.days, dayCode);
    final done =
        today?.exercises.where((exercise) => exercise.done).length ?? 0;
    final total = today?.exercises.length ?? 0;
    final week = plan == null ? null : trainingWeek(plan.startDate, now);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Calendar',
            onPressed: _selectDate,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(workoutControllerProvider);
          ref.invalidate(mealControllerProvider);
          ref.invalidate(profileControllerProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          children: [
            Text(
              'Hey $name',
              style: const TextStyle(
                fontFamily: 'AppSans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${DateFormat('EEEE \u00b7 MMM d').format(now).toUpperCase()}${week == null ? '' : ' \u00b7 WEEK $week'}',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(letterSpacing: 2),
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
                                    : '$dayCode \u00b7 ${isToday ? 'TODAY\'S SESSION' : 'EXERCISE SUMMARY'}',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: AppColors.primaryRed),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                today?.title ??
                                    (plan == null
                                        ? 'Programme pending'
                                        : 'No workout scheduled.'),
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
                    if (!isToday && today != null && !today.rest)
                      for (final exercise in today.exercises)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            '${exercise.name} \u00b7 ${exercise.sets} sets \u00b7 ${exercise.reps} reps',
                          ),
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
            Text(
              "THIS WEEK'S PROGRAMME",
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            WeeklyProgrammeStrip(
              days: plan?.days ?? [],
              selectedDay: dayCode,
              onOpen: (day) => context.push('/client/session/${day.dayOfWeek}'),
            ),
            const SizedBox(height: 26),
            AlfSectionHeader(
              title: isToday ? 'Today\'s meal plan' : 'Meal plan',
              actionLabel: 'FULL PLAN',
              onAction: () => context.push('/client/meals?day=$dayCode'),
            ),
            meals.when(
              data: (mealPlan) {
                final day =
                    mealPlan == null ||
                        selectedDate.isBefore(
                          DateUtils.dateOnly(mealPlan.startDate),
                        )
                    ? null
                    : mealPlan.days
                          .where(
                            (item) => shortPlanDay(item.dayOfWeek) == dayCode,
                          )
                          .firstOrNull;
                if (day == null || day.meals.isEmpty) {
                  return const AlfPanel(
                    child: Text('No meals scheduled for this date.'),
                  );
                }
                return HomeMealGrid(
                  meals: day.meals,
                  onToggle: isToday
                      ? (index) => ref
                            .read(mealControllerProvider.notifier)
                            .toggleMealStatus(
                              mealPlan!.days.indexOf(day),
                              index,
                            )
                      : null,
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
      days.where((day) => shortPlanDay(day.dayOfWeek) == code).firstOrNull;
}
