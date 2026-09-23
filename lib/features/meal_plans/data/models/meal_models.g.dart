// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: invalid_annotation_target

part of 'meal_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientMealPlan _$ClientMealPlanFromJson(Map<String, dynamic> json) =>
    _ClientMealPlan(
      clientId: json['client_id'] as String,
      focus: json['focus'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      trainerNotes: json['trainer_notes'] as String? ?? '',
      days:
          (json['days'] as List<dynamic>?)
              ?.map((e) => MealPlanDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ClientMealPlanToJson(_ClientMealPlan instance) =>
    <String, dynamic>{
      'client_id': instance.clientId,
      'focus': instance.focus,
      'start_date': instance.startDate.toIso8601String(),
      'trainer_notes': instance.trainerNotes,
      'days': instance.days.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_MealPlanDay _$MealPlanDayFromJson(Map<String, dynamic> json) => _MealPlanDay(
  dayOfWeek: json['dayOfWeek'] as String,
  meals:
      (json['meals'] as List<dynamic>?)
          ?.map((e) => AssignedMeal.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  source: json['source'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$MealPlanDayToJson(_MealPlanDay instance) =>
    <String, dynamic>{
      'dayOfWeek': instance.dayOfWeek,
      'meals': instance.meals.map((e) => e.toJson()).toList(),
      'source': instance.source,
    };

_AssignedMeal _$AssignedMealFromJson(Map<String, dynamic> json) =>
    _AssignedMeal(
      id: (json['id'] as num).toInt(),
      time: json['time'] as String,
      name: json['name'] as String,
      kcal: (json['kcal'] as num).toInt(),
      protein: (json['protein'] as num).toInt(),
      eaten: json['eaten'] as bool? ?? false,
      source: json['source'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$AssignedMealToJson(_AssignedMeal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time,
      'name': instance.name,
      'kcal': instance.kcal,
      'protein': instance.protein,
      'eaten': instance.eaten,
      'source': instance.source,
    };
