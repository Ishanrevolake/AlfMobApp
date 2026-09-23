import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/plan_days.dart';
import '../models/meal_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return MealRepository(supabase);
});

class MealRepository {
  final SupabaseClient _supabase;

  MealRepository(this._supabase);

  Future<ClientMealPlan?> getMealPlan(String clientId) async {
    try {
      final data = await _supabase
          .from('client_meal_plans')
          .select()
          .eq('client_id', clientId)
          .maybeSingle();

      if (data == null) return null;
      return ClientMealPlan.fromJson(normalizePlan(data));
    } catch (e) {
      throw Exception('Failed to load meal plan: $e');
    }
  }

  Future<void> updateMealPlan(ClientMealPlan plan) async {
    try {
      final saved = await _supabase
          .from('client_meal_plans')
          .upsert(toDatabase(plan), onConflict: 'client_id')
          .select('client_id')
          .single();
      if (saved['client_id'] != plan.clientId) {
        throw StateError(
          'The meal assignment was not confirmed. Please retry.',
        );
      }
    } catch (e) {
      throw Exception('Failed to update meal plan: $e');
    }
  }

  static Map<String, dynamic> normalizePlan(Map<String, dynamic> data) {
    final rawDays = data['days'] is List ? data['days'] as List : const [];
    final days = <Map<String, dynamic>>[];
    for (var dayIndex = 0; dayIndex < rawDays.length; dayIndex++) {
      final rawDay = Map<String, dynamic>.from(
        rawDays[dayIndex] as Map? ?? const {},
      );
      final rawMeals = rawDay['meals'] is List
          ? rawDay['meals'] as List
          : const [];
      final meals = <Map<String, dynamic>>[];
      for (var mealIndex = 0; mealIndex < rawMeals.length; mealIndex++) {
        final meal = Map<String, dynamic>.from(
          rawMeals[mealIndex] as Map? ?? const {},
        );
        meals.add({
          'id': (dayIndex + 1) * 100 + mealIndex,
          'time': (meal['mealTime'] ?? meal['time'] ?? 'Meal').toString(),
          'name': (meal['name'] ?? 'Meal').toString(),
          'kcal': _asInt(meal['calories'] ?? meal['kcal']),
          'protein': _asInt(meal['protein']),
          'eaten': meal['eaten'] == true,
          'source': meal,
        });
      }
      final label =
          (rawDay['day'] ?? rawDay['dayOfWeek'] ?? 'Day ${dayIndex + 1}')
              .toString();
      days.add({
        'dayOfWeek': shortPlanDay(label),
        'meals': meals,
        'source': rawDay,
      });
    }
    return {
      ...data,
      'client_id': (data['client_id'] ?? '').toString(),
      'focus': (data['focus'] ?? 'Custom nutrition plan').toString(),
      'start_date': (data['start_date'] ?? DateTime.now().toIso8601String())
          .toString(),
      'trainer_notes': (data['trainer_notes'] ?? '').toString(),
      'days': days,
      'created_at': (data['created_at'] ?? DateTime.now().toIso8601String())
          .toString(),
      'updated_at': (data['updated_at'] ?? DateTime.now().toIso8601String())
          .toString(),
    };
  }

  static Map<String, dynamic> toDatabase(ClientMealPlan plan) => {
    'client_id': plan.clientId,
    'focus': plan.focus,
    'start_date': plan.startDate.toIso8601String().split('T').first,
    'trainer_notes': plan.trainerNotes,
    'days': [
      for (var dayIndex = 0; dayIndex < plan.days.length; dayIndex++)
        {
          ...plan.days[dayIndex].source,
          'id': plan.days[dayIndex].source['id'] ?? 'meal-day-${dayIndex + 1}',
          'day': fullPlanDay(plan.days[dayIndex].dayOfWeek),
          'meals': [
            for (final meal in plan.days[dayIndex].meals)
              {
                ...meal.source,
                'id': meal.source['id'] ?? meal.id.toString(),
                'mealTime': meal.time,
                'name': meal.name,
                'calories': _preserveNumber(
                  meal.source['calories'] ?? meal.source['kcal'],
                  meal.kcal,
                ),
                'protein': _preserveNumber(
                  meal.source['protein'],
                  meal.protein,
                ),
                'mealId': meal.source['mealId'] ?? 'custom-meal',
                'items': meal.source['items'] ?? <String>[],
                'foods': meal.source['foods'] ?? <dynamic>[],
                'notes': meal.source['notes'] ?? '',
                'eaten': meal.eaten,
              },
          ],
        },
    ],
    'updated_at': DateTime.now().toIso8601String(),
  };

  static num _preserveNumber(dynamic original, int current) {
    final number = original is num ? original : num.tryParse('$original');
    return number != null && _asInt(original) == current ? number : current;
  }

  static int _asInt(dynamic value) => value is num
      ? value.toInt()
      : num.tryParse(value?.toString() ?? '')?.round() ?? 0;
}
