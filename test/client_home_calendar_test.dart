import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alfalee_app/app/theme/app_theme.dart';
import 'package:alfalee_app/features/dashboard/presentation/screens/client_home_screen.dart';
import 'package:alfalee_app/features/client_profile/presentation/controllers/profile_controller.dart';
import 'package:alfalee_app/features/meal_plans/presentation/controllers/meal_controller.dart';
import 'package:alfalee_app/features/workouts/presentation/controllers/workout_controller.dart';
import 'client_readability_test.dart' show PreviewMeals, PreviewWorkout;

class PreviewProfile extends ProfileController {
  @override
  Future<ProfileState> build() async => ProfileState();
}

void main() {
  testWidgets(
    'home calendar opens a picker and updates summaries without navigation',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileControllerProvider.overrideWith(PreviewProfile.new),
            mealControllerProvider.overrideWith(PreviewMeals.new),
            workoutControllerProvider.overrideWith(PreviewWorkout.new),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ClientHomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ALFA LEE'), findsNothing);
      expect(find.text('Chicken and rice bowl'), findsOneWidget);
      await tester.tap(find.byTooltip('Calendar'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      final now = DateTime.now();
      final monday = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: (DateTime.monday - now.weekday + 7) % 7));
      final picker = tester.widget<CalendarDatePicker>(
        find.byType(CalendarDatePicker),
      );
      picker.onDateChanged(monday);
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsNothing);
      expect(find.byType(ClientHomeScreen), findsOneWidget);
      expect(find.text('Full body strength'), findsOneWidget);
      if (monday.weekday != now.weekday) {
        expect(find.textContaining('Dumbbell bench press'), findsOneWidget);
        expect(find.text('No meals scheduled for this date.'), findsOneWidget);
      }
      await tester.tap(find.byTooltip('Calendar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Full body strength'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

