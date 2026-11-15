import 'fake_daily_logs.dart';
import 'package:alfalee_app/features/progress/data/daily_log_repository.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:alfalee_app/app/client_plan_sync.dart';
import 'package:alfalee_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:alfalee_app/features/workouts/data/models/workout_models.dart';
import 'package:alfalee_app/features/workouts/data/repositories/workout_repository.dart';
import 'package:alfalee_app/features/workouts/presentation/controllers/workout_controller.dart';
import 'plan_editor_test.dart' show FakeWorkouts;

WorkoutPlan samplePlan(String name) => WorkoutPlan.fromJson(
  WorkoutRepository.normalizePlan({
    'client_id': 'client',
    'days': [
      {
        'id': 'monday',
        'day': 'Monday',
        'title': 'Strength',
        'exercises': [
          {'id': 'exercise', 'name': name, 'sets': '3', 'reps': '10'},
        ],
      },
    ],
  }),
);

void main() {
  test(
    'Workout writes confirm the target client and can be loaded by that client',
    () async {
      Map<String, dynamic>? stored;
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          if (request.method == 'POST') {
            expect(request.url.queryParameters['on_conflict'], 'client_id');
            expect(
              request.headers['Prefer'],
              contains('return=representation'),
            );
            stored = jsonDecode(request.body) as Map<String, dynamic>;
            return http.Response(
              '{"client_id":"client"}',
              200,
              request: request,
            );
          }
          expect(request.url.queryParameters['client_id'], 'eq.client');
          return http.Response(jsonEncode([stored]), 200, request: request);
        }),
      );
      final repo = WorkoutRepository(client);
      await repo.updateWorkoutPlan(samplePlan('Squat'));
      final received = await repo.getWorkoutPlan('client');
      expect(received!.days.single.exercises.single.name, 'Squat');
      expect(received.clientId, 'client');
    },
  );

  test('An unconfirmed write cannot report success', () async {
    final repo = WorkoutRepository(
      SupabaseClient(
        'https://example.supabase.co',
        'test',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient(
          (request) async => http.Response('{}', 200, request: request),
        ),
      ),
    );
    await expectLater(
      repo.updateWorkoutPlan(samplePlan('Squat')),
      throwsException,
    );
  });

  testWidgets(
    'An already-open client plan refreshes on a remote change and on resume',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final changes = StreamController<int>.broadcast();
      final repo = FakeWorkouts();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clientPlanChangesProvider.overrideWith((ref) => changes.stream),
            currentUserProvider.overrideWithValue(
              User(
                id: 'client',
                appMetadata: {},
                userMetadata: {},
                aud: 'authenticated',
                createdAt: '2026-09-22T00:00:00Z',
              ),
            ),
            workoutRepositoryProvider.overrideWithValue(repo),
            dailyLogRepositoryProvider.overrideWithValue(MemoryDailyLogs()),
          ],
          child: MaterialApp(
            home: ClientPlanSync(
              child: Scaffold(
                body: Consumer(
                  builder: (context, ref, _) {
                    final state = ref.watch(workoutControllerProvider);
                    return state.when(
                      data: (plan) => Text(
                        plan?.days.first.exercises.first.name ??
                            'No assignment',
                      ),
                      loading: () => const Text('Loading'),
                      error: (error, _) => Text('$error'),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No assignment'), findsOneWidget);
      repo.saved = samplePlan('Squat');
      changes.add(1);
      await tester.pumpAndSettle();
      expect(find.text('Squat'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      repo.saved = samplePlan('Bench press');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Bench press'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await changes.close();
    },
  );
}
