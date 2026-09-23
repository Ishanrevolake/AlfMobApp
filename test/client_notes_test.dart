import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alfalee_app/features/client_profile/data/models/profile_models.dart';
import 'package:alfalee_app/features/meal_plans/data/models/meal_models.dart';
import 'package:alfalee_app/features/meal_plans/data/repositories/meal_repository.dart';
import 'package:alfalee_app/features/workouts/data/models/workout_models.dart';
import 'package:alfalee_app/features/workouts/data/repositories/workout_repository.dart';
import 'package:alfalee_app/features/trainer/data/trainer_repository.dart';
import 'package:alfalee_app/features/trainer/presentation/trainer_client_detail_screen.dart';

class NotesRepository extends TrainerRepository {
  NotesRepository(super.supabase);
  final notes = <Map<String, dynamic>>[];
  Completer<void>? pendingSave;
  @override
  Future<List<Map<String, dynamic>>> getClientNotes(String clientId) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return List.of(notes);
  }

  @override
  Future<void> addClientNote(String clientId, String body) async {
    await pendingSave?.future;
    notes.add({'body': body, 'created_at': '2026-09-18T01:00:00Z'});
  }
}

class EmptyMeals extends MealRepository {
  EmptyMeals(super.supabase);
  @override
  Future<ClientMealPlan?> getMealPlan(String clientId) async => null;
}

class EmptyWorkouts extends WorkoutRepository {
  EmptyWorkouts(super.supabase);
  @override
  Future<WorkoutPlan?> getWorkoutPlan(String clientId) async => null;
}

void main() {
  for (final leaveWhileSaving in [false, true]) {
    testWidgets(
      leaveWhileSaving
          ? 'Finishing a note save after leaving does not refresh disposed state'
          : 'Saving a note refreshes the list and keeps the Notes tab selected',
      (tester) async {
        final client = SupabaseClient(
          'https://example.supabase.co',
          'test',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        );

        final repository = NotesRepository(client);
        if (leaveWhileSaving) repository.pendingSave = Completer<void>();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              trainerRepositoryProvider.overrideWithValue(repository),
              mealRepositoryProvider.overrideWithValue(EmptyMeals(client)),
              workoutRepositoryProvider.overrideWithValue(
                EmptyWorkouts(client),
              ),
            ],
            child: const MaterialApp(
              home: TrainerClientDetailScreen(
                clientId: 'client',
                client: ClientProfile(
                  id: 'client',
                  fullName: 'Test Client',
                  email: '',
                  role: 'client',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(Tab, 'NOTES'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('ADD'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'New coaching note');
        await tester.tap(find.text('SAVE NOTE'));
        await tester.pumpAndSettle();
        if (leaveWhileSaving) {
          await tester.pumpWidget(const MaterialApp(home: SizedBox()));
          repository.pendingSave!.complete();
          await tester.pumpAndSettle();
        } else {
          expect(find.text('New coaching note'), findsOneWidget);
          expect(find.byType(SnackBar), findsNothing);
          final tabs = tester.element(find.byType(TabBar));
          expect(DefaultTabController.of(tabs).index, 3);
        }
        expect(repository.notes.single['body'], 'New coaching note');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
