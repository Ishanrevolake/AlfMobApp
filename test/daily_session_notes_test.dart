import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alfalee_app/app/theme/app_theme.dart';
import 'package:alfalee_app/features/workouts/data/models/workout_models.dart';
import 'package:alfalee_app/features/workouts/data/repositories/workout_repository.dart';
import 'package:alfalee_app/features/workouts/presentation/controllers/workout_controller.dart';
import 'package:alfalee_app/features/workouts/presentation/screens/client_workout_session_screen.dart';
import 'package:alfalee_app/features/workouts/presentation/screens/client_workout_library_screen.dart';
import 'package:alfalee_app/features/trainer/presentation/trainer_plan_editor.dart';
import 'plan_editor_test.dart' show FakeWorkouts;

WorkoutPlan notesPlan() => WorkoutPlan.fromJson(
  WorkoutRepository.normalizePlan({
    'client_id': 'client',
    'start_date': '2026-10-26',
    'days': [
      {
        'day': 'Monday',
        'title': 'Strength',
        'notes': 'Start light and focus on technique.',
        'exercises': [
          {'name': 'Squat', 'sets': '3', 'reps': '10'},
        ],
      },
      {
        'day': 'Tuesday',
        'title': 'Recovery',
        'rest': true,
        'notes': 'Take a gentle walk.',
      },
    ],
  }),
);

class NotesWorkout extends WorkoutController {
  @override
  Future<WorkoutPlan?> build() async => notesPlan();
}

Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
  if (Platform.environment['CAPTURE_REVIEW'] != '1') return;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('tmp/pdfs')..createSync(recursive: true);
    File(
      '${directory.path}/$name.png',
    ).writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    final fonts = FontLoader('AppSans');
    for (final weight in ['regular', 'medium', 'bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/roboto-$weight.ttf'));
    }
    await fonts.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  for (final rest in [false, true]) {
    testWidgets(
      'Client sees the correct note on ${rest ? 'rest' : 'training'} day',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final key = GlobalKey();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              workoutControllerProvider.overrideWith(NotesWorkout.new),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: RepaintBoundary(
                key: key,
                child: ClientWorkoutSessionScreen(
                  dayOfWeek: rest ? 'TUE' : 'MON',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(
            rest
                ? 'Take a gentle walk.'
                : 'Start light and focus on technique.',
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            rest
                ? 'Start light and focus on technique.'
                : 'Take a gentle walk.',
          ),
          findsNothing,
        );
        await capture(
          tester,
          key,
          rest ? 'rest-notes-review' : 'session-notes-review',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Programme lists individual day notes', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [workoutControllerProvider.overrideWith(NotesWorkout.new)],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const ClientWorkoutLibraryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Start light and focus on technique.'), findsOneWidget);
    expect(find.text('Take a gentle walk.'), findsOneWidget);
  });

  testWidgets('Trainer saves day notes without changing the other day', (
    tester,
  ) async {
    final repository = FakeWorkouts()..saved = notesPlan();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [workoutRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          home: TrainerPlanEditor(clientId: 'client', meals: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notes for this day'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField),
      'Warm up for ten minutes.',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    final reloaded = WorkoutPlan.fromJson(
      WorkoutRepository.normalizePlan(
        WorkoutRepository.toDatabase(repository.saved!),
      ),
    );
    expect(reloaded.days[0].trainerNotes, 'Warm up for ten minutes.');
    expect(reloaded.days[1].trainerNotes, 'Take a gentle walk.');
  });
}
