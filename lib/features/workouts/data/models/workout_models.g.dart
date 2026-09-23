// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: invalid_annotation_target

part of 'workout_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutPlan _$WorkoutPlanFromJson(Map<String, dynamic> json) => _WorkoutPlan(
  clientId: json['client_id'] as String,
  assignedProgramId: json['assigned_program_id'] as String,
  focus: json['focus'] as String,
  startDate: DateTime.parse(json['start_date'] as String),
  weeklySchedule:
      (json['weekly_schedule'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  trainerNotes: json['trainer_notes'] as String? ?? '',
  days:
      (json['days'] as List<dynamic>?)
          ?.map((e) => WorkoutDay.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$WorkoutPlanToJson(_WorkoutPlan instance) =>
    <String, dynamic>{
      'client_id': instance.clientId,
      'assigned_program_id': instance.assignedProgramId,
      'focus': instance.focus,
      'start_date': instance.startDate.toIso8601String(),
      'weekly_schedule': instance.weeklySchedule,
      'trainer_notes': instance.trainerNotes,
      'days': instance.days.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_WorkoutDay _$WorkoutDayFromJson(Map<String, dynamic> json) => _WorkoutDay(
  dayOfWeek: json['dayOfWeek'] as String,
  title: json['title'] as String,
  meta: json['meta'] as String,
  rest: json['rest'] as bool? ?? false,
  exercises:
      (json['exercises'] as List<dynamic>?)
          ?.map((e) => AssignedExercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  source: json['source'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$WorkoutDayToJson(_WorkoutDay instance) =>
    <String, dynamic>{
      'dayOfWeek': instance.dayOfWeek,
      'title': instance.title,
      'meta': instance.meta,
      'rest': instance.rest,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
      'source': instance.source,
    };

_AssignedExercise _$AssignedExerciseFromJson(Map<String, dynamic> json) =>
    _AssignedExercise(
      name: json['name'] as String,
      sets: json['sets'] as String,
      reps: json['reps'] as String,
      done: json['done'] as bool? ?? false,
      cue: json['cue'] as String? ?? '',
      source: json['source'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$AssignedExerciseToJson(_AssignedExercise instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sets': instance.sets,
      'reps': instance.reps,
      'done': instance.done,
      'cue': instance.cue,
      'source': instance.source,
    };
