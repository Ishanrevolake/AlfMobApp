import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_models.freezed.dart';
part 'meal_models.g.dart';

@freezed
abstract class ClientMealPlan with _$ClientMealPlan {
  const factory ClientMealPlan({
    @JsonKey(name: 'client_id') required String clientId,
    required String focus,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'trainer_notes') @Default('') String trainerNotes,
    @Default([]) List<MealPlanDay> days,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ClientMealPlan;

  factory ClientMealPlan.fromJson(Map<String, dynamic> json) =>
      _$ClientMealPlanFromJson(json);
}

@freezed
abstract class MealPlanDay with _$MealPlanDay {
  const factory MealPlanDay({
    required String dayOfWeek, // 'MON', 'TUE', etc.
    @Default([]) List<AssignedMeal> meals,
    @Default({}) Map<String, dynamic> source,
  }) = _MealPlanDay;

  factory MealPlanDay.fromJson(Map<String, dynamic> json) =>
      _$MealPlanDayFromJson(json);
}

@freezed
abstract class AssignedMeal with _$AssignedMeal {
  const factory AssignedMeal({
    required int id,
    required String time, // 'Breakfast', 'Lunch', etc.
    required String name,
    required int kcal,
    required int protein,
    @Default(false) bool eaten,
    // Carries web-only fields such as foods, items, carbs, fat and notes so a
    // mobile progress update cannot erase them.
    @Default({}) Map<String, dynamic> source,
  }) = _AssignedMeal;

  factory AssignedMeal.fromJson(Map<String, dynamic> json) =>
      _$AssignedMealFromJson(json);
}
