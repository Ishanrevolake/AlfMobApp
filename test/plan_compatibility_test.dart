import 'package:flutter_test/flutter_test.dart';
import 'package:alfalee_app/features/meal_plans/data/models/meal_models.dart';
import 'package:alfalee_app/features/meal_plans/data/repositories/meal_repository.dart';
import 'package:alfalee_app/features/workouts/data/models/workout_models.dart';
import 'package:alfalee_app/features/workouts/data/repositories/workout_repository.dart';
import 'package:alfalee_app/features/trainer/data/catalog_repository.dart';
import 'package:alfalee_app/shared/plan_days.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Plan start defaults to the next Monday across calendar boundaries', () {
    expect(nextPlanMonday(DateTime(2026, 10, 19, 15)), DateTime(2026, 10, 19));
    expect(nextPlanMonday(DateTime(2026, 10, 22)), DateTime(2026, 10, 26));
    expect(nextPlanMonday(DateTime(2026, 10, 25)), DateTime(2026, 10, 26));
    expect(nextPlanMonday(DateTime(2026, 12, 31)), DateTime(2027, 1, 4));
    for (var offset = 0; offset < 7; offset++) {
      final start = nextPlanMonday(DateTime(2026, 10, 19 + offset));
      expect(start.weekday, DateTime.monday);
      expect(trainingWeek(start, start.add(const Duration(days: 6))), 1);
      expect(trainingWeek(start, start.add(const Duration(days: 7))), 2);
    }
  });
  test('Workout day notes stay with their day when exercises change', () {
    final plan = WorkoutPlan.fromJson(
      WorkoutRepository.normalizePlan({
        'client_id': 'client',
        'days': [
          {
            'day': 'Monday',
            'notes': 'Keep the session light.',
            'exercises': [
              {'name': 'Squat', 'sets': '3', 'reps': '10'},
            ],
          },
          {'day': 'Tuesday', 'notes': 'Recovery walk.', 'rest': true},
          {'day': 'Wednesday'},
        ],
      }),
    );
    expect(plan.days[0].trainerNotes, 'Keep the session light.');
    expect(plan.days[1].trainerNotes, 'Recovery walk.');
    expect(plan.days[2].trainerNotes, isEmpty);
    final updated = plan.copyWith(
      days: [
        plan.days[0].copyWith(
          exercises: [plan.days[0].exercises.single.copyWith(done: true)],
        ),
        ...plan.days.skip(1),
      ],
    );
    final reloaded = WorkoutPlan.fromJson(
      WorkoutRepository.normalizePlan(WorkoutRepository.toDatabase(updated)),
    );
    expect(reloaded.days[0].trainerNotes, 'Keep the session light.');
    expect(reloaded.days[0].exercises.single.done, isTrue);
    expect(reloaded.days[1].trainerNotes, 'Recovery walk.');
    final clearedDay = reloaded.days[0].copyWith(
      source: {
        ...reloaded.days[0].source,
        'trainer_notes': 'Legacy note',
        'notes': '',
      },
    );
    expect(clearedDay.trainerNotes, isEmpty);
  });
  test(
    'Meal round trip keeps web weekdays, identifiers, foods and fractional nutrition',
    () {
      final source = <String, dynamic>{
        'client_id': 'client',
        'days': [
          {
            'id': 'monday-id',
            'day': 'Monday',
            'meals': [
              {
                'id': 'web-meal-id',
                'mealId': 'chicken',
                'name': 'Lunch',
                'mealTime': 'Lunch',
                'calories': 247.5,
                'protein': 46.5,
                'carbs': 12.3,
                'fat': 5.4,
                'notes': 'Trainer note',
                'items': ['150g chicken'],
                'foods': [
                  {
                    'id': 'food-row',
                    'foodId': 'chicken',
                    'grams': 150,
                    'protein': 46.5,
                  },
                ],
              },
            ],
          },
        ],
      };
      final plan = ClientMealPlan.fromJson(
        MealRepository.normalizePlan(source),
      );
      expect(plan.days.single.dayOfWeek, 'MON');
      final updated = plan.copyWith(
        days: [
          plan.days.single.copyWith(
            meals: [plan.days.single.meals.single.copyWith(eaten: true)],
          ),
        ],
      );
      final output = MealRepository.toDatabase(updated);
      final day = (output['days'] as List).single as Map;
      expect(day['day'], 'Monday');
      expect(day['id'], 'monday-id');
      final meal = (day['meals'] as List).single as Map;
      expect(meal, containsPair('id', 'web-meal-id'));
      expect(meal, containsPair('calories', 247.5));
      expect(meal, containsPair('protein', 46.5));
      expect(meal, containsPair('carbs', 12.3));
      expect(meal, containsPair('eaten', true));
      expect(
        meal['foods'],
        ((source['days'] as List).single['meals'] as List).single['foods'],
      );
      expect(meal['items'], ['150g chicken']);
    },
  );
  test('New mobile meals include the fields consumed by the web UI', () {
    final now = DateTime(2026, 9, 18);
    final plan = ClientMealPlan(
      clientId: 'client',
      focus: 'Plan',
      startDate: now,
      createdAt: now,
      updatedAt: now,
      days: [
        const MealPlanDay(
          dayOfWeek: 'TUE',
          meals: [
            AssignedMeal(
              id: 1,
              time: 'Lunch',
              name: 'Rice',
              kcal: 100,
              protein: 2,
            ),
          ],
        ),
      ],
    );
    final day = (MealRepository.toDatabase(plan)['days'] as List).single;
    expect(day['day'], 'Tuesday');
    final meal = (day['meals'] as List).single;
    expect(meal['items'], isEmpty);
    expect(meal['foods'], isEmpty);
    expect(meal['mealId'], isNotEmpty);
    expect(meal['notes'], '');
  });
  test(
    'Workout editing preserves prescription and regenerates weekly schedule',
    () {
      final plan = WorkoutPlan.fromJson(
        WorkoutRepository.normalizePlan({
          'client_id': 'client',
          'weekly_schedule': ['Old schedule'],
          'days': [
            {
              'id': 'day-x',
              'day': 'Wednesday',
              'title': 'Upper body',
              'exercises': [
                {
                  'id': 'row-x',
                  'exerciseId': 'bench',
                  'name': 'Bench press',
                  'sets': '3',
                  'reps': '8-12',
                  'rest': '90 sec',
                  'tempo': '3-1-1',
                  'notes': 'Controlled descent',
                },
              ],
            },
          ],
        }),
      );
      final output = WorkoutRepository.toDatabase(plan);
      expect(output['weekly_schedule'], ['Wednesday - Upper body']);
      final day = (output['days'] as List).single;
      expect(day['day'], 'Wednesday');
      final exercise = (day['exercises'] as List).single;
      expect(exercise['id'], 'row-x');
      expect(exercise['exerciseId'], 'bench');
      expect(exercise['rest'], '90 sec');
      expect(exercise['tempo'], '3-1-1');
      expect(exercise['notes'], 'Controlled descent');
    },
  );
  test(
    'Legacy weekdays are repaired without truncating arbitrary workout day labels',
    () {
      expect(fullPlanDay(' day 2 '), 'Tuesday');
      expect(shortPlanDay('Day 7'), 'SUN');
      expect(shortPlanDay('Day 10'), 'Day 10');
      expect(fullPlanDay('MON'), 'Monday');
    },
  );
  test('Food portions and meal totals match dashboard calculations', () {
    final food = <String, dynamic>{
      'id': 'chicken',
      'name': 'Chicken',
      'basis': 'cooked',
      'calories': 165,
      'protein': 31,
      'carbs': 0,
      'fat': 3.6,
      'sodium': 74,
    };
    final portion = foodPortion(food, 150, id: 'portion');
    expect(portion['calories'], 247.5);
    expect(portion['protein'], 46.5);
    expect(portion['fat'], 5.4);
    expect(portion['sodium'], 111);
    final meal = <String, dynamic>{
      'foods': [portion, foodPortion(food, 100)],
    };
    calculateMealNutrition(meal);
    expect(meal['calories'], 412.5);
    expect(meal['protein'], 77.5);
    expect(meal['items'], ['150g Chicken (cooked)', '100g Chicken (cooked)']);
    meal['foods'] = <PlanRecord>[];
    calculateMealNutrition(meal);
    expect(meal['calories'], 0);
    expect(meal['items'], isEmpty);
  });
  test(
    'Bundled catalogs contain the dashboard data and stable food ids',
    () async {
      final meals = await loadCatalog('meals');
      final foods = await loadCatalog('foods');
      final exercises = await loadCatalog('exercises');
      expect(meals.length, 40);
      expect(foods.length, 86);
      expect(exercises.length, 176);
      expect(meals.first['id'], 'bread-and-egg-scramble');
      expect(foods.first['id'], 'eggs-whole-raw-0');
      expect(foods.map((f) => f['id']).toSet().length, foods.length);
    },
  );
}
