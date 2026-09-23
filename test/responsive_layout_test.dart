import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alfalee_app/app/theme/app_theme.dart';
import 'package:alfalee_app/features/trainer/data/catalog_repository.dart';
import 'package:alfalee_app/features/trainer/presentation/trainer_pages.dart';
import 'package:alfalee_app/features/trainer/presentation/plan_forms.dart';
import 'package:alfalee_app/features/navigation/presentation/app_shells.dart';
import 'package:alfalee_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:alfalee_app/shared/widgets/responsive_layout.dart';

import 'package:alfalee_app/features/dashboard/presentation/screens/client_home_screen.dart';
import 'package:alfalee_app/features/client_profile/presentation/screens/client_profile_screen.dart';
import 'package:alfalee_app/features/client_profile/presentation/controllers/profile_controller.dart';
import 'package:alfalee_app/features/client_profile/data/models/profile_models.dart';
import 'package:alfalee_app/features/ask_alpha/presentation/screens/client_ask_alpha_screen.dart';
import 'package:alfalee_app/features/ask_alpha/presentation/controllers/ask_alpha_controller.dart';
import 'package:alfalee_app/features/ask_alpha/data/models/ask_alpha_models.dart';
import 'package:alfalee_app/features/meal_plans/presentation/controllers/meal_controller.dart';
import 'package:alfalee_app/features/workouts/presentation/controllers/workout_controller.dart';
import 'client_readability_test.dart' show PreviewMeals, PreviewWorkout;

class PreviewProfile extends ProfileController {
  @override
  Future<ProfileState> build() async => ProfileState(
    profile: const ClientProfile(
      id: 'client',
      fullName: 'Alexandra Longname',
      email: 'client@example.com',
      role: 'client',
    ),
  );
}

class PreviewAsk extends AskAlphaController {
  @override
  Future<AskAlphaState> build() async => AskAlphaState(
    credits: 3,
    orders: [
      AskAlphaOrder.fromJson({
        'id': 'order',
        'product_title': 'Three question coaching pack',
        'status': 'pending_verification',
      }),
    ],
  );
}

const exercises = [
  {
    'id': 'long',
    'name': 'Wide grip T-bar row chest supported',
    'category': 'Back',
    'equipment': 'T-Bar',
    'primary': 'Lats, Mid Back',
    'level': 'Intermediate',
  },
  {
    'id': 'short',
    'name': 'Rows',
    'category': 'Back',
    'equipment': 'Free Weight',
    'primary': 'Lats',
    'level': 'Beginner',
  },
];
const meals = [
  {
    'id': 'rice',
    'name': 'Rice and curry',
    'category': 'Main Meal',
    'items': [
      '150g cooked rice',
      '100g chicken breast',
      '1-2 tablespoons of soy sauce and coconut or olive oil',
      'One whole egg',
      '200g vegetables',
    ],
  },
  {
    'id': 'toast',
    'name': 'Toast',
    'category': 'Main Meal',
    'items': ['Bread', 'Egg'],
  },
];
const destinations = [
  NavigationDestination(icon: Icon(Icons.home), label: 'OVERVIEW'),
  NavigationDestination(icon: Icon(Icons.people), label: 'CLIENTS'),
  NavigationDestination(icon: Icon(Icons.event), label: 'PROGRAMS'),
  NavigationDestination(icon: Icon(Icons.grid_view), label: 'LIBRARY'),
  NavigationDestination(icon: Icon(Icons.more_horiz), label: 'MORE'),
];

Future<void> mount(
  WidgetTester tester,
  Size size,
  double scale,
  Widget home,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        exerciseCatalogProvider.overrideWith((ref) async => exercises),
        mealCatalogProvider.overrideWith((ref) async => meals),
        trainerClientsProvider.overrideWith((ref) async => []),
        trainerPaymentsProvider.overrideWith((ref) async => []),
        trainerThreadsProvider.overrideWith((ref) async => []),
        currentUserProvider.overrideWithValue(null),
        profileControllerProvider.overrideWith(PreviewProfile.new),
        askAlphaControllerProvider.overrideWith(PreviewAsk.new),
        workoutControllerProvider.overrideWith(PreviewWorkout.new),
        mealControllerProvider.overrideWith(PreviewMeals.new),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: AlfAppViewport(child: child!),
        ),
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> reveal(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 30 && finder.hitTestable().evaluate().isEmpty; i++) {
    await tester.drag(
      find
          .byWidgetPredicate(
            (widget) =>
                widget is Scrollable &&
                widget.axisDirection == AxisDirection.down,
          )
          .last,
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
  }
  expect(finder.hitTestable(), findsWidgets);
}

void main() {
  setUpAll(() async {
    final loader = FontLoader('AppSans');
    for (final name in ['regular', 'medium', 'bold']) {
      loader.addFont(rootBundle.load('assets/fonts/roboto-$name.ttf'));
    }
    await loader.load();
  });
  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(844, 390),
    const Size(768, 1024),
    const Size(1440, 900),
  ]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('Library and navigation fit $size at $scale text scale', (
        tester,
      ) async {
        var selected = -1;
        await mount(
          tester,
          size,
          scale,
          Scaffold(
            body: const TrainerLibraryPage(),
            bottomNavigationBar: AlfNavigationBar(
              index: 3,
              onSelect: (index) => selected = index,
              destinations: destinations,
            ),
          ),
        );
        final cards = find.byType(Card);
        await reveal(tester, find.text('Wide grip T-bar row chest supported'));
        await tester.pumpAndSettle();
        expect(
          tester.getSize(cards.at(0)).width,
          tester.getSize(cards.at(1)).width,
        );
        final first = tester.getRect(cards.at(0));
        expect(first.left, greaterThanOrEqualTo(0));
        expect(first.right, lessThanOrEqualTo(size.width));
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('MORE'));
        expect(selected, 4);
        await tester.drag(find.byType(ListView).first, const Offset(0, 2000));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Meals'));
        await tester.pumpAndSettle();
        await reveal(tester, find.text('View meal details'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('View meal details').first);
        await tester.pumpAndSettle();
        expect(find.text('Show less'), findsOneWidget);
        expect(find.textContaining('200g vegetables'), findsOneWidget);
        expect(
          tester.getSize(cards.at(0)).width,
          tester.getSize(cards.at(1)).width,
        );
        expect(tester.takeException(), isNull);
      });
      testWidgets('Trainer overview fits $size at $scale text scale', (
        tester,
      ) async {
        await mount(
          tester,
          size,
          scale,
          const Scaffold(body: TrainerOverviewPage()),
        );
        await tester.drag(find.byType(ListView).first, const Offset(0, -700));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
  for (final screen in <Widget>[
    const ClientHomeScreen(),
    const ClientProfileScreen(),
    const ClientAskAlphaScreen(),
    const Scaffold(body: TrainerClientsPage()),
    const Scaffold(body: TrainerMorePage()),
  ]) {
    for (final size in [const Size(320, 640), const Size(844, 390)]) {
      testWidgets('${screen.runtimeType} fits $size with large text', (
        tester,
      ) async {
        await mount(tester, size, 1.5, screen);
        final lists = find.byType(ListView);
        if (lists.evaluate().isNotEmpty) {
          for (var i = 0; i < 5; i++) {
            await tester.drag(lists.first, const Offset(0, -220));
            await tester.pumpAndSettle();
          }
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('Credit purchase sheet scrolls in landscape with large text', (
    tester,
  ) async {
    await mount(
      tester,
      const Size(640, 360),
      1.5,
      const ClientAskAlphaScreen(),
    );
    await reveal(tester, find.text('BUY CREDITS'));
    await tester.tap(find.text('BUY CREDITS'));
    await tester.pumpAndSettle();
    await reveal(tester, find.text('SUBMIT FOR VERIFICATION'));
    expect(tester.takeException(), isNull);
  });
  testWidgets('Catalog picker remains scrollable in landscape with keyboard', (
    tester,
  ) async {
    await mount(
      tester,
      const Size(640, 360),
      1.5,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                pickCatalog(context, 'Choose an exercise', exercises),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 150);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Rows');
    await tester.pumpAndSettle();
    await reveal(tester, find.widgetWithText(ListTile, 'Rows'));
    await tester.tap(find.widgetWithText(ListTile, 'Rows'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
