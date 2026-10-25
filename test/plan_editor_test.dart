import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alfalee_app/features/meal_plans/data/models/meal_models.dart';
import 'package:alfalee_app/features/meal_plans/data/repositories/meal_repository.dart';
import 'package:alfalee_app/features/trainer/data/catalog_repository.dart';
import 'package:alfalee_app/features/trainer/presentation/trainer_plan_editor.dart';
import 'package:alfalee_app/features/trainer/presentation/plan_forms.dart';
import 'package:alfalee_app/features/workouts/data/models/workout_models.dart';
import 'package:alfalee_app/features/workouts/data/repositories/workout_repository.dart';
import 'package:alfalee_app/shared/plan_days.dart';

class FakeWorkouts extends WorkoutRepository {
  FakeWorkouts()
    : super(
        SupabaseClient(
          'https://example.supabase.co',
          'test',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );
  WorkoutPlan? saved;
  bool fail = false;
  int writes = 0;
  @override
  Future<WorkoutPlan?> getWorkoutPlan(String clientId) async => saved;
  @override
  Future<void> updateWorkoutPlan(WorkoutPlan plan) async {
    if (fail) throw StateError('Workout save failed');
    writes++;
    saved = plan;
  }
}

class FakeMeals extends MealRepository {
  FakeMeals()
    : super(
        SupabaseClient(
          'https://example.supabase.co',
          'test',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );
  ClientMealPlan? saved;
  bool fail = false;
  @override
  Future<ClientMealPlan?> getMealPlan(String clientId) async => saved;
  @override
  Future<void> updateMealPlan(ClientMealPlan plan) async {
    if (fail) throw StateError('Save failed for test');
    saved = plan;
  }
}

void main() {
  testWidgets('New workout plans default to the next Monday', (tester) async {
    final repo = FakeWorkouts();
    final expected = nextPlanMonday(
      DateTime.now(),
    ).toIso8601String().split('T').first;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [workoutRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(
          home: TrainerPlanEditor(clientId: 'client', meals: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Starts $expected'), findsOneWidget);
  });

  testWidgets(
    'Workout start picker allows Mondays and preserves legacy dates on cancel',
    (tester) async {
      final repo = FakeWorkouts();
      repo.saved = WorkoutPlan.fromJson(
        WorkoutRepository.normalizePlan({
          'client_id': 'client',
          'start_date': '2026-10-22',
          'focus': 'Strength',
          'days': [],
        }),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [workoutRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(
            home: TrainerPlanEditor(clientId: 'client', meals: false),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Strength'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      final picker = tester.widget<DatePickerDialog>(
        find.byType(DatePickerDialog),
      );
      expect(picker.initialDate, DateTime(2026, 10, 26));
      for (var day = 19; day <= 25; day++) {
        final date = DateTime(2026, 10, day);
        expect(
          picker.selectableDayPredicate!(date),
          date.weekday == DateTime.monday,
        );
      }
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Starts 2026-10-22'), findsOneWidget);
      expect(repo.writes, 0);
    },
  );

  testWidgets(
    'Exercise dialog retries a failed publish without duplicating the assignment',
    (tester) async {
      final repo = FakeWorkouts()..fail = true;
      repo.saved = WorkoutPlan.fromJson(
        WorkoutRepository.normalizePlan({
          'client_id': 'client',
          'days': [
            {
              'id': 'monday',
              'day': 'Monday',
              'title': 'Strength',
              'exercises': [],
            },
          ],
        }),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [workoutRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(
            home: TrainerPlanEditor(
              clientId: 'client',
              meals: false,
              template: {'id': 'squat', 'name': 'Squat'},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Workout save failed'), findsOneWidget);
      expect(repo.saved!.days.single.exercises, isEmpty);
      expect(find.byType(AlertDialog), findsOneWidget);
      repo.fail = false;
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(repo.saved!.days.single.exercises.single.name, 'Squat');
      expect(repo.writes, 1);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text("Exercise saved to the client's plan."), findsOneWidget);
    },
  );
  testWidgets('Deleting the last workout day clears its legacy schedule', (
    tester,
  ) async {
    final repository = FakeWorkouts()
      ..saved = WorkoutPlan.fromJson(
        WorkoutRepository.normalizePlan({
          'client_id': 'client',
          'days': [],
          'weekly_schedule': ['Monday - Upper body'],
        }),
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [workoutRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          home: TrainerPlanEditor(clientId: 'client', meals: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Upper body'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove day'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    expect(repository.saved!.days, isEmpty);
    expect(repository.saved!.weeklySchedule, isEmpty);
  });
  testWidgets(
    'Workout template assignment saves exercise identity and prescription',
    (tester) async {
      final repository = FakeWorkouts()
        ..saved = WorkoutPlan.fromJson(
          WorkoutRepository.normalizePlan({
            'client_id': 'client',
            'days': [
              {
                'id': 'day',
                'day': 'Monday',
                'title': 'Strength',
                'exercises': [],
              },
            ],
          }),
        );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [workoutRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(
            home: TrainerPlanEditor(
              clientId: 'client',
              meals: false,
              template: {'id': 'bench', 'name': 'Bench press'},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(3), '90 sec');
      await tester.enterText(fields.at(4), '3-1-1');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      final exercise = repository.saved!.days.single.exercises.single;
      expect(exercise.source['exerciseId'], 'bench');
      expect(exercise.source['rest'], '90 sec');
      expect(exercise.source['tempo'], '3-1-1');
    },
  );
  testWidgets(
    'Template assignment to every day saves independent meals in web format',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = FakeMeals();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [mealRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(
            home: TrainerPlanEditor(
              clientId: 'client',
              meals: true,
              template: {
                'id': 'oats',
                'name': 'Oats',
                'items': ['50g oats'],
                'notes': '',
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add meal'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Every day').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.text('Oats'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();
      final output = MealRepository.toDatabase(repository.saved!);
      final days = output['days'] as List;
      expect(days.length, 7);
      expect(days.first['day'], 'Monday');
      expect(days.last['day'], 'Sunday');
      expect(days.every((day) => (day['meals'] as List).length == 1), isTrue);
      expect(days.map((day) => day['meals'][0]['id']).toSet().length, 7);
      expect(days.first['meals'][0]['items'], ['50g oats']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Failed saves retain the draft for retry', (tester) async {
    final repository = FakeMeals()..fail = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mealRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          home: TrainerPlanEditor(clientId: 'client', meals: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add meal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'My lunch');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Save failed for test'), findsOneWidget);
    expect(find.text('My lunch'), findsOneWidget);
    repository.fail = false;
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    expect(repository.saved!.days.first.meals.single.name, 'My lunch');
  });

  testWidgets(
    'Form rejects empty names and invalid portions, retaining values',
    (tester) async {
      PlanRecord? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await editPlanFields(
                    context,
                    'Food',
                    {'name': '', 'grams': 100},
                    const [
                      PlanField('name', 'Name', required: true),
                      PlanField('grams', 'Grams', number: true),
                    ],
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).last, '-5');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Enter a non-negative number'), findsOneWidget);
      expect(result, isNull);
      await tester.enterText(find.byType(TextFormField).first, 'Chicken');
      await tester.enterText(find.byType(TextFormField).last, '150.5');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(result!['grams'], 150.5);
    },
  );
}
