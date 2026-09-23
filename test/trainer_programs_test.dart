import 'package:alfalee_app/app/theme/app_theme.dart';
import 'package:alfalee_app/features/trainer/data/program_packages.dart';
import 'package:alfalee_app/features/trainer/data/trainer_repository.dart';
import 'package:alfalee_app/features/trainer/presentation/trainer_programs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PackageRepository extends TrainerRepository {
  PackageRepository(super.supabase);
  bool fail = false;
  bool failSave = false;
  bool blockDelete = false;
  int count = 2;
  int deleteCalls = 0;
  final records = <Map<String, dynamic>>[
    {
      'id': 'annual',
      'title': 'Annual Package',
      'subtitle': '12 Months',
      'price_lkr': 148500,
      'category': 'Annual',
    },
  ];
  @override
  Future<List<ManagedPackage>> getPackages() async {
    if (fail) throw StateError('Unable to load packages');
    return records
        .map((row) => ManagedPackage(Map.of(row), clientCount: count))
        .toList();
  }

  @override
  Future<void> savePackage({
    String? id,
    required String name,
    required String duration,
    required int price,
    required String description,
    required String category,
  }) async {
    if (failSave) {
      throw const PackageOperationException('Save failed. Try again.');
    }
    final data = {
      'id': id ?? 'new',
      'title': name,
      'subtitle': duration,
      'price_lkr': price,
      'detail_subtitle': description,
      'category': category,
    };
    if (id == null) {
      records.add(data);
    } else {
      records[records.indexWhere((row) => row['id'] == id)] = data;
    }
  }

  @override
  Future<void> deletePackage(String id) async {
    deleteCalls++;
    if (blockDelete) {
      throw const PackageOperationException(assignedPackageMessage);
    }
    records.removeWhere((row) => row['id'] == id);
  }
}

Future<PackageRepository> setup(
  WidgetTester tester, {
  bool fail = false,
  int count = 2,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final repo =
      PackageRepository(
          SupabaseClient(
            'https://example.supabase.co',
            'test',
            authOptions: const AuthClientOptions(autoRefreshToken: false),
          ),
        )
        ..fail = fail
        ..count = count;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [trainerRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(body: TrainerProgramsPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('Packages can be searched, refreshed and retried after failure', (
    tester,
  ) async {
    final repository = await setup(tester, fail: true);
    expect(find.text('Retry'), findsOneWidget);
    repository.fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), ' ANNUAL ');
    await tester.pumpAndSettle();
    expect(find.text('Annual Package'), findsOneWidget);
    expect(find.text('2 clients'), findsOneWidget);
    repository.count = 3;
    await tester.drag(find.byType(ListView), const Offset(0, 350));
    await tester.pumpAndSettle();
    expect(find.text('3 clients'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'no matching package');
    await tester.pumpAndSettle();
    expect(find.text('No packages found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Assigned packages show a notification instead of deleting', (
    tester,
  ) async {
    final repo = await setup(tester);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text(assignedPackageMessage), findsOneWidget);
    expect(repo.deleteCalls, 0);
    expect(repo.records, hasLength(1));
  });

  testWidgets(
    'Removal can be cancelled and handles a new assignment before deletion',
    (tester) async {
      final repo = await setup(tester, count: 0);
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repo.deleteCalls, 0);
      repo.blockDelete = true;
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Remove').last);
      await tester.pumpAndSettle();
      expect(find.text(assignedPackageMessage), findsOneWidget);
      expect(repo.records, hasLength(1));
      repo.blockDelete = false;
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Remove').last);
      await tester.pumpAndSettle();
      expect(find.text('No packages yet'), findsOneWidget);
      expect(repo.records, isEmpty);
    },
  );

  testWidgets(
    'Add validates inputs, retains a failed draft and persists a new package',
    (tester) async {
      final repo = await setup(tester, count: 0);
      await tester.tap(find.text('Add package'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a package name'), findsOneWidget);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Strength');
      await tester.enterText(fields.at(1), '6 Weeks');
      await tester.enterText(fields.at(2), '-1');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid whole-rupee price'), findsOneWidget);
      await tester.enterText(fields.at(2), '15000');
      repo.failSave = true;
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Save failed. Try again.'), findsOneWidget);
      expect(find.text('Strength'), findsOneWidget);
      repo.failSave = false;
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repo.records.last['title'], 'Strength');
      expect(repo.records.last['price_lkr'], 15000);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets('Edit loads existing values and keeps the package identity', (
    tester,
  ) async {
    final repo = await setup(tester);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('12 Months'), findsOneWidget);
    expect(find.text('148500'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Annual Coaching');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repo.records.single['id'], 'annual');
    expect(find.text('Annual Coaching'), findsOneWidget);
    expect(find.text('2 clients'), findsOneWidget);
  });
}
