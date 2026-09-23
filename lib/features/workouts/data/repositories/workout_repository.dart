import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/plan_days.dart';
import '../models/workout_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return WorkoutRepository(supabase);
});

class WorkoutRepository {
  final SupabaseClient _supabase;

  WorkoutRepository(this._supabase);

  Future<WorkoutPlan?> getWorkoutPlan(String clientId) async {
    try {
      final data = await _supabase
          .from('client_workout_plans')
          .select()
          .eq('client_id', clientId)
          .maybeSingle();

      if (data == null) return null;
      return WorkoutPlan.fromJson(normalizePlan(data));
    } catch (e) {
      throw Exception('Failed to load workout plan: $e');
    }
  }

  Future<void> updateWorkoutPlan(WorkoutPlan plan) async {
    try {
      final saved = await _supabase
          .from('client_workout_plans')
          .upsert(toDatabase(plan), onConflict: 'client_id')
          .select('client_id')
          .single();
      if (saved['client_id'] != plan.clientId) {
        throw StateError(
          'The workout assignment was not confirmed. Please retry.',
        );
      }
    } catch (e) {
      throw Exception('Failed to update workout plan: $e');
    }
  }

  static Map<String, dynamic> normalizePlan(Map<String, dynamic> data) {
    final rawDays = data['days'] is List ? data['days'] as List : const [];
    final days = <Map<String, dynamic>>[];
    for (var dayIndex = 0; dayIndex < rawDays.length; dayIndex++) {
      final rawDay = Map<String, dynamic>.from(
        rawDays[dayIndex] as Map? ?? const {},
      );
      final rawExercises = rawDay['exercises'] is List
          ? rawDay['exercises'] as List
          : const [];
      final exercises = <Map<String, dynamic>>[];
      for (
        var exerciseIndex = 0;
        exerciseIndex < rawExercises.length;
        exerciseIndex++
      ) {
        final exercise = Map<String, dynamic>.from(
          rawExercises[exerciseIndex] as Map? ?? const {},
        );
        exercises.add({
          'name': (exercise['name'] ?? 'Exercise').toString(),
          'sets': (exercise['sets'] ?? '1').toString(),
          'reps': (exercise['reps'] ?? '').toString(),
          'done': exercise['done'] == true,
          'cue': (exercise['notes'] ?? exercise['cue'] ?? '').toString(),
          'source': exercise,
        });
      }
      final label =
          (rawDay['day'] ?? rawDay['dayOfWeek'] ?? 'Day ${dayIndex + 1}')
              .toString();
      days.add({
        'dayOfWeek': shortPlanDay(label),
        'title': (rawDay['title'] ?? 'Workout').toString(),
        'meta': (rawDay['meta'] ?? '${exercises.length} exercises').toString(),
        'rest': rawDay['rest'] == true,
        'exercises': exercises,
        'source': rawDay,
      });
    }
    return {
      ...data,
      'client_id': (data['client_id'] ?? '').toString(),
      'assigned_program_id':
          (data['assigned_program_id'] ?? 'custom-workout-plan').toString(),
      'focus': (data['focus'] ?? 'Custom workout plan').toString(),
      'start_date': (data['start_date'] ?? DateTime.now().toIso8601String())
          .toString(),
      'weekly_schedule': data['weekly_schedule'] is List
          ? data['weekly_schedule']
          : <String>[],
      'trainer_notes': (data['trainer_notes'] ?? '').toString(),
      'days': days,
      'created_at': (data['created_at'] ?? DateTime.now().toIso8601String())
          .toString(),
      'updated_at': (data['updated_at'] ?? DateTime.now().toIso8601String())
          .toString(),
    };
  }

  static Map<String, dynamic> toDatabase(WorkoutPlan plan) => {
    'client_id': plan.clientId,
    'assigned_program_id': plan.assignedProgramId,
    'focus': plan.focus,
    'start_date': plan.startDate.toIso8601String().split('T').first,
    'weekly_schedule': plan.days.isEmpty
        ? plan.weeklySchedule
        : [
            for (final day in plan.days)
              '${fullPlanDay(day.dayOfWeek)} - ${day.title}',
          ],
    'trainer_notes': plan.trainerNotes,
    'days': [
      for (var dayIndex = 0; dayIndex < plan.days.length; dayIndex++)
        {
          ...plan.days[dayIndex].source,
          'id': plan.days[dayIndex].source['id'] ?? 'day-${dayIndex + 1}',
          'day': fullPlanDay(plan.days[dayIndex].dayOfWeek),
          'title': plan.days[dayIndex].title,
          'meta': plan.days[dayIndex].meta,
          'rest': plan.days[dayIndex].rest,
          'exercises': [
            for (
              var exerciseIndex = 0;
              exerciseIndex < plan.days[dayIndex].exercises.length;
              exerciseIndex++
            )
              {
                ...plan.days[dayIndex].exercises[exerciseIndex].source,
                'id':
                    plan.days[dayIndex].exercises[exerciseIndex].source['id'] ??
                    'exercise-${dayIndex + 1}-${exerciseIndex + 1}',
                'exerciseId':
                    plan
                        .days[dayIndex]
                        .exercises[exerciseIndex]
                        .source['exerciseId'] ??
                    'custom-exercise',
                'rest':
                    plan
                        .days[dayIndex]
                        .exercises[exerciseIndex]
                        .source['rest'] ??
                    '',
                'tempo':
                    plan
                        .days[dayIndex]
                        .exercises[exerciseIndex]
                        .source['tempo'] ??
                    '',
                'name': plan.days[dayIndex].exercises[exerciseIndex].name,
                'sets': plan.days[dayIndex].exercises[exerciseIndex].sets,
                'reps': plan.days[dayIndex].exercises[exerciseIndex].reps,
                'done': plan.days[dayIndex].exercises[exerciseIndex].done,
                'notes': plan.days[dayIndex].exercises[exerciseIndex].cue,
              },
          ],
        },
    ],
    'updated_at': DateTime.now().toIso8601String(),
  };
}
