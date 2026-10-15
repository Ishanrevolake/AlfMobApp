import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alfalee_app/features/meal_plans/presentation/controllers/meal_controller.dart';
import 'package:alfalee_app/features/meal_plans/presentation/widgets/home_meal_grid.dart';
import 'client_progress_test.dart' show ControlledProgress, clientContainer;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final fail in [false, true]) {
    testWidgets(
      fail
          ? 'card save failure rolls back without success notification'
          : 'card tick and untick persist through reopening',
      (tester) async {
        final progress = ControlledProgress()..fail = fail;
        final container = clientContainer('alice', progress);
        final containers = [container];
        await container.read(mealControllerProvider.future);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, _) {
                    final day = ref
                        .watch(mealControllerProvider)
                        .value!
                        .days
                        .first;
                    return HomeMealGrid(
                      meals: day.meals,
                      onToggle: (index) => ref
                          .read(mealControllerProvider.notifier)
                          .toggleMealStatus(0, index),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(Checkbox).at(1));
        await tester.pumpAndSettle();
        final reopened = clientContainer('alice', progress);
        containers.add(reopened);
        expect(
          (await reopened.read(
            mealControllerProvider.future,
          ))!.days.first.meals.first.eaten,
          !fail,
        );
        expect(
          tester.widget<Checkbox>(find.byType(Checkbox).at(1)).value,
          !fail,
        );
        if (fail) {
          expect(find.text('Meal logged'), findsNothing);
          expect(find.textContaining('Unable to update meal'), findsOneWidget);
        } else {
          expect(find.text('Meal logged'), findsOneWidget);
          await tester.tap(find.byType(Checkbox).at(1));
          await tester.pumpAndSettle();
          expect(
            tester.widget<Checkbox>(find.byType(Checkbox).at(1)).value,
            false,
          );
          expect(find.text('Unmarked'), findsOneWidget);
          final reopenedAgain = clientContainer('alice', progress);
          containers.add(reopenedAgain);
          expect(
            (await reopenedAgain.read(
              mealControllerProvider.future,
            ))!.days.first.meals.first.eaten,
            false,
          );
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        for (final item in containers) {
          item.invalidate(mealControllerProvider);
        }
        await tester.pump(const Duration(milliseconds: 1));
      },
    );
  }
}

