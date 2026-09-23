import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/meal_models.dart';
import '../../data/repositories/meal_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../progress/data/client_progress_repository.dart';

class MealController extends AsyncNotifier<ClientMealPlan?> {
  late MealRepository _repository;
  late String _clientId;
  bool _saving = false;

  @override
  FutureOr<ClientMealPlan?> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return null;

    _clientId = user.id;
    _repository = ref.watch(mealRepositoryProvider);

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
    final plan = await _repository.getMealPlan(_clientId);
    if (plan == null) return null;
    final values = await progress.read([
      for (final day in plan.days)
        for (final item in day.meals) _progressKey(progress, plan, day, item),
    ]);
    return plan.copyWith(
      days: [
        for (final day in plan.days)
          day.copyWith(
            meals: [
              for (final item in day.meals)
                item.copyWith(
                  eaten:
                      values[_progressKey(progress, plan, day, item)] ?? false,
                ),
            ],
          ),
      ],
    );
  }

  String _progressKey(
    ClientProgressRepository progress,
    ClientMealPlan plan,
    MealPlanDay day,
    AssignedMeal item,
  ) => progress.key(
    plan.clientId,
    'meals',
    plan.startDate,
    (day.source['id'] ?? day.dayOfWeek).toString(),
    (item.source['id'] ?? '${item.name}:${day.meals.indexOf(item)}').toString(),
  );

  Future<void> toggleMealStatus(int dayIndex, int mealIndex) async {
    final currentState = state.value;
    if (currentState == null || _saving) return;
    if (dayIndex < 0 ||
        dayIndex >= currentState.days.length ||
        mealIndex < 0 ||
        mealIndex >= currentState.days[dayIndex].meals.length) {
      return;
    }
    _saving = true;

    final days = List<MealPlanDay>.from(currentState.days);
    final day = days[dayIndex];
    final meals = List<AssignedMeal>.from(day.meals);
    final meal = meals[mealIndex];

    meals[mealIndex] = meal.copyWith(eaten: !meal.eaten);
    days[dayIndex] = day.copyWith(meals: meals);

    final updatedPlan = currentState.copyWith(
      days: days,
      updatedAt: DateTime.now(),
    );

    // Optimistic UI update
    state = AsyncData(updatedPlan);

    try {
      final progress = ref.read(clientProgressRepositoryProvider);
      await progress.write(
        _progressKey(progress, currentState, day, meal),
        !meal.eaten,
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

final mealControllerProvider =
    AsyncNotifierProvider<MealController, ClientMealPlan?>(() {
      return MealController();
    });
