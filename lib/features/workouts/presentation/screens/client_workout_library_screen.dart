import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/plan_days.dart';
import '../controllers/workout_controller.dart';
import 'client_workout_session_screen.dart';

class ClientWorkoutLibraryScreen extends ConsumerWidget {
  const ClientWorkoutLibraryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workoutControllerProvider);
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('TRAIN')),
        body: Center(
          child: TextButton(
            onPressed: () => ref.invalidate(workoutControllerProvider),
            child: const Text('Unable to load programme. Retry'),
          ),
        ),
      ),
      data: (plan) {
        final now = DateTime.now();
        final today = shortPlanDay(weekDays[now.weekday - 1]);
        final day = plan?.days
            .where((d) => shortPlanDay(d.dayOfWeek) == today)
            .firstOrNull;
        if (plan == null ||
            day == null ||
            DateTime(now.year, now.month, now.day).isBefore(
              DateTime(
                plan.startDate.year,
                plan.startDate.month,
                plan.startDate.day,
              ),
            )) {
          return Scaffold(
            appBar: AppBar(title: const Text('TRAIN')),
            body: const Center(child: Text('No workout scheduled for today.')),
          );
        }
        return ClientWorkoutSessionScreen(
          dayOfWeek: day.dayOfWeek,
          showBack: false,
        );
      },
    );
  }
}
