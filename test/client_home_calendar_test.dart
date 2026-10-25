import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alfalee_app/features/dashboard/presentation/screens/client_calendar_screen.dart';
import 'package:alfalee_app/features/dashboard/presentation/widgets/weekly_programme_strip.dart';
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
    'home programme sits above the session and calendar opens the calendar screen',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, __) => const ClientHomeScreen()),
          GoRoute(
            path: '/client/calendar',
            builder: (_, __) => const ClientCalendarScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileControllerProvider.overrideWith(PreviewProfile.new),
            mealControllerProvider.overrideWith(PreviewMeals.new),
            workoutControllerProvider.overrideWith(PreviewWorkout.new),
          ],
          child: MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ALFA LEE'), findsNothing);
      expect(find.text('Chicken and rice bowl'), findsOneWidget);
      expect(
        tester.getTopLeft(find.byType(WeeklyProgrammeStrip)).dy,
        lessThan(tester.getTopLeft(find.byType(ElevatedButton).first).dy),
      );
      await tester.tap(find.byTooltip('Calendar'));
      await tester.pumpAndSettle();
      expect(find.byType(ClientCalendarScreen), findsOneWidget);
      expect(find.byType(CalendarDatePicker), findsOneWidget);
      expect(find.text('Chicken and rice bowl'), findsOneWidget);
      final picker = tester.widget<CalendarDatePicker>(
        find.byType(CalendarDatePicker),
      );
      picker.onDateChanged(DateTime(2026, 10, 2));
      await tester.pumpAndSettle();
      expect(find.text('FRIDAY \u00b7 OCT 2'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(ClientHomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
