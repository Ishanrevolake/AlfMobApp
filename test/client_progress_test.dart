import 'fake_daily_logs.dart';
import 'package:alfalee_app/features/progress/data/daily_log_repository.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alfalee_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:alfalee_app/features/progress/data/client_progress_repository.dart';
import 'package:alfalee_app/features/meal_plans/data/models/meal_models.dart';
import 'package:alfalee_app/features/meal_plans/data/repositories/meal_repository.dart';
import 'package:alfalee_app/features/meal_plans/presentation/controllers/meal_controller.dart';
import 'package:alfalee_app/features/workouts/data/models/workout_models.dart';
import 'package:alfalee_app/features/workouts/data/repositories/workout_repository.dart';
import 'package:alfalee_app/features/workouts/presentation/controllers/workout_controller.dart';

final _supabase = SupabaseClient(
  'https://example.supabase.co',
  'test',
  authOptions: const AuthClientOptions(autoRefreshToken: false),
);
final _cloudLogs = MemoryDailyLogs();
final _start = DateTime(2026, 9, 14);

class ClientMeals extends MealRepository {
  ClientMeals(this.clientId) : super(_supabase);
  final String clientId;
  int writes = 0;
  @override
  Future<ClientMealPlan?> getMealPlan(String id) async => ClientMealPlan(
    clientId: clientId,
    focus: 'Meals',
    startDate: _start,
    createdAt: _start,
    updatedAt: _start,
    days: const [
      MealPlanDay(
        dayOfWeek: 'MON',
        source: {'id': 'monday'},
        meals: [
          AssignedMeal(
            id: 1,
            time: 'Lunch',
            name: 'Lunch',
            kcal: 500,
            protein: 30,
            source: {'id': 'lunch'},
          ),
        ],
      ),
    ],
  );
  @override
  Future<void> updateMealPlan(ClientMealPlan plan) async {
    writes++;
    throw StateError('Client plan writes are forbidden');
  }
}

class ClientWorkouts extends WorkoutRepository {
  ClientWorkouts(this.clientId) : super(_supabase);
  final String clientId;
  int writes = 0;
  @override
  Future<WorkoutPlan?> getWorkoutPlan(String id) async => WorkoutPlan(
    clientId: clientId,
    assignedProgramId: 'program',
    focus: 'Training',
    startDate: _start,
    createdAt: _start,
    updatedAt: _start,
    days: const [
      WorkoutDay(
        dayOfWeek: 'MON',
        title: 'Strength',
        meta: '',
        source: {'id': 'monday'},
        exercises: [
          AssignedExercise(
            name: 'Squat',
            sets: '3',
            reps: '10',
            source: {'id': 'squat'},
          ),
        ],
      ),
    ],
  );
  @override
  Future<void> updateWorkoutPlan(WorkoutPlan plan) async {
    writes++;
    throw StateError('Client plan writes are forbidden');
  }
}

class ControlledProgress extends ClientProgressRepository {
  ControlledProgress() : super(now: () => DateTime(2026, 9, 18));
  bool fail = false;
  Completer<void>? pending;
  int writes = 0;
  @override
  Future<void> write(String key, bool completed) async {
    writes++;
    await pending?.future;
    if (fail) throw StateError('Storage unavailable');
    return super.write(key, completed);
  }
}

ProviderContainer clientContainer(
  String id,
  ClientProgressRepository progress, {
  ClientMeals? meals,
  ClientWorkouts? workouts,
}) {
  final container = ProviderContainer(
    overrides: [
      currentUserProvider.overrideWithValue(
        User(
          id: id,
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-09-14T00:00:00Z',
        ),
      ),
      mealRepositoryProvider.overrideWithValue(meals ?? ClientMeals(id)),
      workoutRepositoryProvider.overrideWithValue(
        workouts ?? ClientWorkouts(id),
      ),
      clientProgressRepositoryProvider.overrideWithValue(progress),
      dailyLogRepositoryProvider.overrideWithValue(_cloudLogs),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _cloudLogs.values.clear();
  });
  test(
    'Meal and workout check-offs persist without writing trainer plans',
    () async {
      final meals = ClientMeals('alice');
      final workouts = ClientWorkouts('alice');
      final progress = ControlledProgress();
      final container = clientContainer(
        'alice',
        progress,
        meals: meals,
        workouts: workouts,
      );
      await container.read(mealControllerProvider.future);
      await container.read(workoutControllerProvider.future);
      await container
          .read(mealControllerProvider.notifier)
          .toggleMealStatus(0, 0);
      await container
          .read(workoutControllerProvider.notifier)
          .toggleExerciseStatus(0, 0);
      expect(meals.writes, 0);
      expect(workouts.writes, 0);
      final reopened = clientContainer('alice', progress);
      expect(
        (await reopened.read(
          mealControllerProvider.future,
        ))!.days.single.meals.single.eaten,
        isTrue,
      );
      expect(
        (await reopened.read(
          workoutControllerProvider.future,
        ))!.days.single.exercises.single.done,
        isTrue,
      );
      await reopened
          .read(mealControllerProvider.notifier)
          .toggleMealStatus(0, 0);
      await reopened
          .read(workoutControllerProvider.notifier)
          .toggleExerciseStatus(0, 0);
      final reopenedAgain = clientContainer('alice', progress);
      expect(
        (await reopenedAgain.read(
          mealControllerProvider.future,
        ))!.days.single.meals.single.eaten,
        isFalse,
      );
      expect(
        (await reopenedAgain.read(
          workoutControllerProvider.future,
        ))!.days.single.exercises.single.done,
        isFalse,
      );
    },
  );
  test(
    'Progress is isolated by account and resets for the next week',
    () async {
      final progress = ControlledProgress();
      final alice = clientContainer('alice', progress);
      await alice.read(mealControllerProvider.future);
      await alice.read(workoutControllerProvider.future);
      await alice.read(mealControllerProvider.notifier).toggleMealStatus(0, 0);
      await alice
          .read(workoutControllerProvider.notifier)
          .toggleExerciseStatus(0, 0);
      for (final container in [
        clientContainer('bob', progress),
        clientContainer(
          'alice',
          ClientProgressRepository(now: () => DateTime(2026, 9, 21)),
        ),
      ]) {
        expect(
          (await container.read(
            mealControllerProvider.future,
          ))!.days.single.meals.single.eaten,
          isFalse,
        );
        expect(
          (await container.read(
            workoutControllerProvider.future,
          ))!.days.single.exercises.single.done,
          isFalse,
        );
      }
    },
  );
  test(
    'Storage failures roll back check-offs and keep the plan visible for retry',
    () async {
      final progress = ControlledProgress()..fail = true;
      final container = clientContainer('alice', progress);
      await container.read(mealControllerProvider.future);
      await container.read(workoutControllerProvider.future);
      await expectLater(
        container.read(mealControllerProvider.notifier).toggleMealStatus(0, 0),
        throwsStateError,
      );
      await expectLater(
        container
            .read(workoutControllerProvider.notifier)
            .toggleExerciseStatus(0, 0),
        throwsStateError,
      );
      expect(container.read(mealControllerProvider).hasError, isFalse);
      expect(container.read(workoutControllerProvider).hasError, isFalse);
      expect(
        container
            .read(mealControllerProvider)
            .value!
            .days
            .single
            .meals
            .single
            .eaten,
        isFalse,
      );
      expect(
        container
            .read(workoutControllerProvider)
            .value!
            .days
            .single
            .exercises
            .single
            .done,
        isFalse,
      );
      progress.fail = false;
      await container
          .read(workoutControllerProvider.notifier)
          .toggleExerciseStatus(0, 0);
      expect(
        container
            .read(workoutControllerProvider)
            .value!
            .days
            .single
            .exercises
            .single
            .done,
        isTrue,
      );
    },
  );
  test(
    'Rapid repeated taps cannot create overlapping progress saves',
    () async {
      final progress = ControlledProgress()..pending = Completer<void>();
      final container = clientContainer('alice', progress);
      await container.read(workoutControllerProvider.future);
      final controller = container.read(workoutControllerProvider.notifier);
      final first = controller.toggleExerciseStatus(0, 0);
      await controller.toggleExerciseStatus(0, 0);
      expect(progress.writes, 1);
      progress.pending!.complete();
      await first;
      expect(
        container
            .read(workoutControllerProvider)
            .value!
            .days
            .single
            .exercises
            .single
            .done,
        isTrue,
      );
    },
  );
  test('Progress keys distinguish plans, days, and items', () {
    final progress = ControlledProgress();
    final keys = [
      progress.key('a', 'meals', _start, 'mon', 'one'),
      progress.key('b', 'meals', _start, 'mon', 'one'),
      progress.key('a', 'exercises', _start, 'mon', 'one'),
      progress.key('a', 'meals', DateTime(2026, 9, 15), 'mon', 'one'),
      progress.key('a', 'meals', _start, 'tue', 'one'),
      progress.key('a', 'meals', _start, 'mon', 'two'),
    ];
    expect(keys.toSet().length, keys.length);
  });
}
