import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alfalee_app/app/theme/app_theme.dart';
import 'package:alfalee_app/app/theme/app_colors.dart';
import 'package:alfalee_app/features/meal_plans/data/models/meal_models.dart';
import 'package:alfalee_app/features/meal_plans/presentation/widgets/home_meal_grid.dart';

void main() {
  for (final eaten in [false, true]) {
    testWidgets(
      eaten ? 'unticking shows Unmarked' : 'ticking shows Meal logged',
      (tester) async {
        var toggled = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: HomeMealGrid(
                meals: [
                  AssignedMeal(
                    id: 1,
                    time: 'Lunch',
                    name: 'Rice bowl',
                    kcal: 400,
                    protein: 30,
                    eaten: eaten,
                  ),
                ],
                onToggle: (index) async {
                  expect(index, 0);
                  toggled = true;
                },
              ),
            ),
          ),
        );
        await tester.tap(find.byType(Checkbox).at(1));
        await tester.pumpAndSettle();
        expect(toggled, isTrue);
        expect(find.text(eaten ? 'Unmarked' : 'Meal logged'), findsOneWidget);
        expect(
          tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
          AppColors.primaryRed,
        );
      },
    );
  }
  testWidgets(
    'six meal cards show only kcal and protein and open recipe details',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: HomeMealGrid(
                  meals: [
                    AssignedMeal(
                      id: 1,
                      time: 'Breakfast',
                      name: 'Greek Yoghurt & Berry Bowl',
                      kcal: 280,
                      protein: 24,
                      source: {
                        'items': ['200g yoghurt', '50g berries'],
                        'instructions': 'Combine yoghurt and berries.',
                        'carbs': 30,
                        'fat': 8,
                      },
                    ),
                    AssignedMeal(
                      id: 2,
                      time: 'Other',
                      name: 'Excluded meal',
                      kcal: 50,
                      protein: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final category in homeMealCategories) {
        expect(find.text(category.toUpperCase()), findsOneWidget);
      }
      expect(find.byType(Checkbox), findsNWidgets(6));
      expect(find.text('Excluded meal'), findsNothing);
      expect(find.textContaining('280 kcal'), findsOneWidget);
      expect(find.textContaining('Carbs'), findsNothing);
      expect(find.text('200g yoghurt'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Greek Yoghurt & Berry Bowl'));
      await tester.pumpAndSettle();
      expect(find.text('Ingredients'), findsOneWidget);
      expect(find.text('200g yoghurt'), findsOneWidget);
      expect(find.text('Instructions'), findsOneWidget);
      expect(find.text('Combine yoghurt and berries.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
