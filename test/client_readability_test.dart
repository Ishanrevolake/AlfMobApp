import 'fake_daily_logs.dart';
import 'package:alfalee_app/features/progress/data/daily_log_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alfalee_app/app/theme/app_theme.dart';
import 'package:alfalee_app/features/meal_plans/data/models/meal_models.dart';
import 'package:alfalee_app/features/meal_plans/presentation/controllers/meal_controller.dart';
import 'package:alfalee_app/features/meal_plans/presentation/screens/client_meals_screen.dart';
import 'package:alfalee_app/features/workouts/data/models/workout_models.dart';
import 'package:alfalee_app/features/workouts/presentation/controllers/workout_controller.dart';
import 'package:alfalee_app/features/workouts/presentation/screens/client_workout_session_screen.dart';
import 'package:alfalee_app/shared/plan_days.dart';

class PreviewMeals extends MealController {
  @override
  Future<ClientMealPlan?> build() async {
    final today = DateTime.now();
    return ClientMealPlan(
      clientId: 'test',
      focus: 'Custom nutrition plan',
      startDate: today,
      createdAt: today,
      updatedAt: today,
      days: [
        MealPlanDay(
          dayOfWeek: shortPlanDay(weekDays[today.weekday - 1]),
          source: const {'id': 'meal-day'},
          meals: const [
            AssignedMeal(
              id: 1,
              time: 'Breakfast',
              name: 'Chicken and rice bowl',
              kcal: 450,
              protein: 35,
              source: {
                'id': 'meal',
                'items': ['150g chicken breast', '100g cooked rice'],
                'carbs': 40,
                'fat': 10,
              },
            ),
          ],
        ),
      ],
    );
  }
}

class PreviewWorkout extends WorkoutController {
  @override
  Future<WorkoutPlan?> build() async {
    final today = DateTime.now();
    return WorkoutPlan(
      clientId: 'test',
      assignedProgramId: 'strength',
      focus: 'Strength',
      startDate: today,
      createdAt: today,
      updatedAt: today,
      days: const [
        WorkoutDay(
          dayOfWeek: 'MON',
          title: 'Full body strength',
          meta: '1 exercise',
          source: {'id': 'workout-day'},
          exercises: [
            AssignedExercise(
              name: 'Dumbbell bench press',
              sets: '3',
              reps: '8-12',
              cue: 'Controlled descent',
              source: {'id': 'bench', 'rest': '90 seconds', 'tempo': '3-1-1'},
            ),
          ],
        ),
      ],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('AppSans');
    for (final name in ['regular', 'medium', 'bold']) {
      loader.addFont(rootBundle.load('assets/fonts/roboto-$name.ttf'));
    }
    await loader.load();
  });
  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(844, 390),
    const Size(768, 1024),
  ]) {
    for (final meals in [true, false]) {
      testWidgets(
        '${meals ? 'Meal' : 'Workout'} screen supports larger readable text and check-offs at $size',
        (tester) async {
          SharedPreferences.setMockInitialValues({});
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                dailyLogRepositoryProvider.overrideWithValue(MemoryDailyLogs()),
                mealControllerProvider.overrideWith(PreviewMeals.new),
                workoutControllerProvider.overrideWith(PreviewWorkout.new),
              ],
              child: MaterialApp(
                theme: AppTheme.darkTheme,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.5)),
                  child: child!,
                ),
                home: meals
                    ? const ClientMealsScreen()
                    : const ClientWorkoutSessionScreen(dayOfWeek: 'MON'),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final title = find.text(
            meals ? 'Chicken and rice bowl' : 'Dumbbell bench press',
          );
          await tester.ensureVisible(title);
          await tester.tap(meals ? find.byType(Checkbox).first : title);
          await tester.pumpAndSettle();
          if (meals) {
            expect(
              tester.widget<Checkbox>(find.byType(Checkbox).first).value,
              isTrue,
            );
          } else {
            expect(find.text('Log your sets'), findsOneWidget);
          }
          expect(find.textContaining('PostgrestException'), findsNothing);
          expect(tester.takeException(), isNull);
          if (!meals) {
            expect(find.textContaining('90 seconds'), findsOneWidget);
            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  }
}
