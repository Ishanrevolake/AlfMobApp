import '../../../../shared/plan_days.dart';
import '../../../progress/data/daily_log_repository.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/workout_models.dart';
import '../../data/repositories/workout_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../progress/data/client_progress_repository.dart';

class WorkoutController extends AsyncNotifier<WorkoutPlan?> {
  late WorkoutRepository _repository;
  late String _clientId;
  bool _saving = false;

  @override
  FutureOr<WorkoutPlan?> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return null;

    _clientId = user.id;
    _repository = ref.watch(workoutRepositoryProvider);

    final progress = ref.watch(clientProgressRepositoryProvider);
    final current = progress.now();
    final timer = Timer(
      DateTime(
        current.year,
        current.month,
        current.day + 1,
      ).difference(current),
      () => ref.invalidateSelf(),
    );
    ref.onDispose(timer.cancel);
    final plan = await _repository.getWorkoutPlan(_clientId);
    if (plan == null) return null;
    final values = await progress.read([
      for (final day in plan.days)
        for (final item in day.exercises)
          _progressKey(progress, plan, day, item),
    ]);
    final cloud = <String, Map<String, dynamic>>{};
    for (final day in plan.days) {
      final index = weekDays.indexWhere(
        (d) => shortPlanDay(d) == shortPlanDay(day.dayOfWeek),
      );
      final date = DateTime(
        current.year,
        current.month,
        current.day - current.weekday + 1 + (index < 0 ? 0 : index),
      );
      cloud.addAll(
        await ref
            .watch(dailyLogRepositoryProvider)
            .read(_clientId, date, 'exercise'),
      );
    }
    return plan.copyWith(
      days: [
        for (final day in plan.days)
          day.copyWith(
            exercises: [
              for (final item in day.exercises)
                item.copyWith(
                  done:
                      cloud['${logDate(plan.startDate)}:${day.dayOfWeek}:${item.source['id'] ?? day.exercises.indexOf(item)}']?['complete']
                          as bool? ??
                      values[_progressKey(progress, plan, day, item)] ??
                      false,
                ),
            ],
          ),
      ],
    );
  }

  String _progressKey(
    ClientProgressRepository progress,
    WorkoutPlan plan,
    WorkoutDay day,
    AssignedExercise item,
  ) => progress.key(
    plan.clientId,
    'exercises',
    plan.startDate,
    (day.source['id'] ?? day.dayOfWeek).toString(),
    (item.source['id'] ?? '${item.name}:${day.exercises.indexOf(item)}')
        .toString(),
  );

  Future<void> toggleExerciseStatus(int dayIndex, int exerciseIndex) async {
    final currentState = state.value;
    if (currentState == null || _saving) return;
    if (dayIndex < 0 ||
        dayIndex >= currentState.days.length ||
        exerciseIndex < 0 ||
        exerciseIndex >= currentState.days[dayIndex].exercises.length) {
      return;
    }
    _saving = true;

    final days = List<WorkoutDay>.from(currentState.days);
    final day = days[dayIndex];
    final exercises = List<AssignedExercise>.from(day.exercises);
    final exercise = exercises[exerciseIndex];

    exercises[exerciseIndex] = exercise.copyWith(done: !exercise.done);
    days[dayIndex] = day.copyWith(exercises: exercises);

    final updatedPlan = currentState.copyWith(
      days: days,
      updatedAt: DateTime.now(),
    );

    // Optimistic UI update
    state = AsyncData(updatedPlan);

    try {
      final progress = ref.read(clientProgressRepositoryProvider);
      await progress.write(
        _progressKey(progress, currentState, day, exercise),
        !exercise.done,
      );
    } catch (e) {
      // Revert if failed
      if (ref.mounted && identical(state.value, updatedPlan)) {
        state = AsyncData(currentState);
      }
      rethrow;
    } finally {
      _saving = false;
    }
  }
}

final workoutControllerProvider =
    AsyncNotifierProvider<WorkoutController, WorkoutPlan?>(() {
      return WorkoutController();
    });
