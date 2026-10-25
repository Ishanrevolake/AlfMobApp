import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_models.freezed.dart';
part 'workout_models.g.dart';

@freezed
abstract class WorkoutPlan with _$WorkoutPlan {
  const WorkoutPlan._();

  const factory WorkoutPlan({
    @JsonKey(name: 'client_id') required String clientId,
    @JsonKey(name: 'assigned_program_id') required String assignedProgramId,
    required String focus,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'weekly_schedule') @Default([]) List<String> weeklySchedule,
    @JsonKey(name: 'trainer_notes') @Default('') String trainerNotes,
    @Default([]) List<WorkoutDay> days,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _WorkoutPlan;

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) =>
      _$WorkoutPlanFromJson(json);
}

@freezed
abstract class WorkoutDay with _$WorkoutDay {
  const WorkoutDay._();

  /// Day-specific guidance stored alongside the day's exercises in Supabase.
  String get trainerNotes =>
      (source['notes'] ?? source['trainer_notes'] ?? '').toString();

  const factory WorkoutDay({
    required String dayOfWeek, // 'MON', 'TUE', etc.
    required String title,
    required String meta,
    @Default(false) bool rest,
    @Default([]) List<AssignedExercise> exercises,
    // Keeps fields used by the web dashboard (ids and future additions) intact
    // when the mobile app only changes completion state.
    @Default({}) Map<String, dynamic> source,
  }) = _WorkoutDay;

  factory WorkoutDay.fromJson(Map<String, dynamic> json) =>
      _$WorkoutDayFromJson(json);
}

@freezed
abstract class AssignedExercise with _$AssignedExercise {
  const AssignedExercise._();

  const factory AssignedExercise({
    required String name,
    required String sets,
    required String reps,
    @Default(false) bool done,
    @Default('') String cue,
    @Default({}) Map<String, dynamic> source,
  }) = _AssignedExercise;

  factory AssignedExercise.fromJson(Map<String, dynamic> json) =>
      _$AssignedExerciseFromJson(json);
}
