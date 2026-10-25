import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/plan_days.dart';
import '../../../../shared/widgets/alf_widgets.dart';
import '../../../workouts/presentation/controllers/workout_controller.dart';
import '../../../meal_plans/presentation/controllers/meal_controller.dart';
import '../../../meal_plans/presentation/widgets/meal_details.dart';

class ClientCalendarScreen extends ConsumerStatefulWidget {
  const ClientCalendarScreen({super.key});
  @override
  ConsumerState<ClientCalendarScreen> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<ClientCalendarScreen> {
  DateTime selected = DateUtils.dateOnly(DateTime.now());
  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(workoutControllerProvider);
    final meals = ref.watch(mealControllerProvider);
    final code = shortPlanDay(weekDays[selected.weekday - 1]);
    final plan = workout.value;
    final mealPlan = meals.value;
    final day =
        plan == null || selected.isBefore(DateUtils.dateOnly(plan.startDate))
        ? null
        : plan.days.where((d) => shortPlanDay(d.dayOfWeek) == code).firstOrNull;
    final mealDay =
        mealPlan == null ||
            selected.isBefore(DateUtils.dateOnly(mealPlan.startDate))
        ? null
        : mealPlan.days
              .where((d) => shortPlanDay(d.dayOfWeek) == code)
              .firstOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('CALENDAR')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CalendarDatePicker(
            initialDate: selected,
            firstDate: DateTime(DateTime.now().year - 1),
            lastDate: DateTime(DateTime.now().year + 5, 12, 31),
            onDateChanged: (date) => setState(() => selected = date),
          ),
          Text(DateFormat('EEEE \u00b7 MMM d').format(selected).toUpperCase()),
          const SizedBox(height: 8),
          if (plan != null)
            Text('WEEK ${trainingWeek(plan.startDate, selected)}'),
          const SizedBox(height: 20),
          const AlfSectionHeader(title: 'Exercise summary'),
          workout.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AlfAsyncError(error: error),
            data: (_) => AlfPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day?.title ?? 'No workout scheduled.'),
                  if (day != null) ...[
                    const SizedBox(height: 8),
                    Text(day.rest ? 'Recovery day' : day.meta),
                    const SizedBox(height: 12),
                    Text(
                      'Session notes',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      day.trainerNotes.trim().isEmpty
                          ? 'No notes from your trainer for this day yet.'
                          : day.trainerNotes,
                    ),
                    for (final exercise in day.exercises)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${exercise.name} \u00b7 ${exercise.sets} sets \u00b7 ${exercise.reps} reps',
                        ),
                      ),
                    TextButton(
                      onPressed: () =>
                          context.push('/client/session/${day.dayOfWeek}'),
                      child: const Text('VIEW WORKOUT'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const AlfSectionHeader(title: 'Meal plan'),
          meals.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AlfAsyncError(error: error),
            data: (_) => AlfPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mealDay == null || mealDay.meals.isEmpty)
                    const Text('No meals scheduled.'),
                  for (final meal in mealDay?.meals ?? [])
                    ListTile(
                      onTap: () => openMealDetails(context, meal),
                      contentPadding: EdgeInsets.zero,
                      title: Text(meal.name),
                      subtitle: Text(
                        '${meal.time} \u00b7 ${meal.kcal} kcal \u00b7 ${meal.protein}g protein',
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Shows your current assigned weekly plans repeating from their start dates.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
