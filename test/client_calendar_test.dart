import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alfalee_app/app/theme/app_theme.dart';
import 'package:alfalee_app/shared/plan_days.dart';
import 'package:alfalee_app/features/dashboard/presentation/screens/client_calendar_screen.dart';
import 'package:alfalee_app/features/meal_plans/presentation/controllers/meal_controller.dart';
import 'package:alfalee_app/features/workouts/presentation/controllers/workout_controller.dart';
import 'client_readability_test.dart' show PreviewMeals, PreviewWorkout;

void main() {
  test('training weeks change after each seven calendar days', () {
    final start = DateTime(2026, 8, 11, 23);
    expect(trainingWeek(start, DateTime(2026, 8, 11)), 1);
    expect(trainingWeek(start, DateTime(2026, 8, 17)), 1);
    expect(trainingWeek(start, DateTime(2026, 8, 18)), 2);
    expect(trainingWeek(start, DateTime(2026, 8, 25)), 3);
  });
  testWidgets('calendar displays assigned meals and supports changing dates', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealControllerProvider.overrideWith(PreviewMeals.new),
          workoutControllerProvider.overrideWith(PreviewWorkout.new),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const ClientCalendarScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    expect(find.text('Chicken and rice bowl'), findsOneWidget);
    final picker = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    picker.onDateChanged(DateTime.now().add(const Duration(days: 1)));
    await tester.pumpAndSettle();
    expect(find.text('No meals scheduled.'), findsOneWidget);
    expect(find.text('Chicken and rice bowl'), findsNothing);
    final now = DateTime.now();
    final nextMonday = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: (DateTime.monday - now.weekday + 7) % 7));
    picker.onDateChanged(nextMonday);
    await tester.pumpAndSettle();
    expect(find.text('Full body strength'), findsOneWidget);
    expect(find.textContaining('Dumbbell bench press'), findsOneWidget);
    picker.onDateChanged(nextMonday.add(const Duration(days: 1)));
    await tester.pumpAndSettle();
    expect(find.text('No workout scheduled.'), findsOneWidget);
    expect(find.textContaining('Dumbbell bench press'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
