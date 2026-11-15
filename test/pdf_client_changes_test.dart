import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alfalee_app/app/theme/app_theme.dart';
import 'package:alfalee_app/features/progress/data/daily_log_repository.dart';
import 'package:alfalee_app/features/meal_plans/presentation/controllers/meal_controller.dart';
import 'package:alfalee_app/features/meal_plans/presentation/screens/client_meals_screen.dart';
import 'client_readability_test.dart' show PreviewMeals;
import 'fake_daily_logs.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('AppSans');
    for (final name in ['regular', 'medium', 'bold']) {
      font.addFont(rootBundle.load('assets/fonts/roboto-$name.ttf'));
    }
    await font.load();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  testWidgets(
    'dated meals count extras, keep dates separate, and show save failures',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final logs = MemoryDailyLogs();
      final key = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyLogRepositoryProvider.overrideWithValue(logs),
            mealControllerProvider.overrideWith(PreviewMeals.new),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: RepaintBoundary(key: key, child: const ClientMealsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('450\nKcal planned'), findsOneWidget);
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(find.text('450\nKcal eaten'), findsOneWidget);
      await tester.ensureVisible(find.text('Add extra meal'));
      await tester.tap(find.text('Add extra meal'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Banana');
      await tester.enterText(find.byType(TextFormField).at(1), '100');
      await tester.enterText(find.byType(TextFormField).at(2), '1');
      await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);
      await tester.drag(find.byType(ListView).first, const Offset(0, 600));
      await tester.pumpAndSettle();
      expect(find.text('550\nKcal eaten'), findsOneWidget);
      expect(find.text('36g\nProtein eaten'), findsOneWidget);
      await tester.tap(find.byTooltip('Next week'));
      await tester.pumpAndSettle();
      expect(find.text('0\nKcal eaten'), findsOneWidget);
      await tester.tap(find.byTooltip('Previous week'));
      await tester.pumpAndSettle();
      expect(find.text('550\nKcal eaten'), findsOneWidget);
      logs.fail = true;
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(
        find.text('Could not save meal. Please try again.'),
        findsOneWidget,
      );
      expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, true);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 5));
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('tmp/review').create(recursive: true);
        await File(
          'tmp/review/meals.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
      });
    },
  );
}
