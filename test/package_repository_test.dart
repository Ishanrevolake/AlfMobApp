import 'dart:convert';
import 'package:alfalee_app/features/trainer/data/program_packages.dart';
import 'package:alfalee_app/features/trainer/data/trainer_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

TrainerRepository repository(
  Future<http.Response> Function(http.Request) handler,
) => TrainerRepository(
  SupabaseClient(
    'https://example.supabase.co',
    'test',
    httpClient: MockClient((request) async {
      final response = await handler(request);
      return http.Response(
        response.body,
        response.statusCode,
        headers: response.headers,
        request: request,
      );
    }),
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  ),
);

void main() {
  test(
    'Packages count distinct linked clients using stable IDs despite title changes',
    () async {
      final repo = repository(
        (request) async => http.Response(
          jsonEncode(
            request.url.path.endsWith('/packages')
                ? [
                    {
                      'id': 'a',
                      'title': 'Renamed',
                      'subtitle': '3 Months',
                      'price_lkr': 1000,
                    },
                  ]
                : [
                    {'id': '1', 'package_id': 'a', 'user_id': 'u1'},
                    {'id': '2', 'package_id': 'a', 'user_id': 'u1'},
                    {'id': '3', 'package_id': 'a', 'user_id': 'u2'},
                  ],
          ),
          200,
        ),
      );
      final items = await repo.getPackages();
      expect(items.single.clientCount, 2);
      expect(items.single.name, 'Renamed');
      expect(items.single.duration, '3 Months');
    },
  );

  test(
    'Create supplies required database fields and edit only patches editable fields',
    () async {
      final requests = <http.Request>[];
      final repo = repository((request) async {
        requests.add(request);
        return http.Response(
          jsonEncode(
            request.method == 'PATCH'
                ? [
                    {'id': 'saved'},
                  ]
                : {'id': 'saved'},
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      await repo.savePackage(
        name: ' New ',
        duration: '6 Weeks',
        price: 2000,
        description: 'Details',
        category: 'Bundles',
      );
      final created = jsonDecode(requests.single.body) as Map;
      expect(created['id'], startsWith('package-'));
      expect(created['title'], 'New');
      expect(created['features'], isEmpty);
      expect(created['is_active'], true);
      expect(
        created.keys,
        containsAll(['letter', 'footer_text', 'example', 'detail_subtitle']),
      );
      await repo.savePackage(
        id: 'original-id',
        name: 'Changed',
        duration: '3 Months',
        price: 2500,
        description: 'New description',
        category: 'Bundles',
      );
      expect(requests.last.method, 'PATCH');
      expect(requests.last.url.queryParameters['id'], 'eq.original-id');
      expect(
        (jsonDecode(requests.last.body) as Map).keys,
        unorderedEquals([
          'title',
          'subtitle',
          'price_lkr',
          'detail_subtitle',
          'category',
        ]),
      );
    },
  );

  test('Assigned package never sends a DELETE', () async {
    final repo = repository((request) async {
      expect(request.method, 'GET');
      expect(request.url.queryParameters['package_id'], 'eq.assigned');
      return http.Response('[{"id":"selection"}]', 200);
    });
    await expectLater(
      repo.deletePackage('assigned'),
      throwsA(
        isA<PackageOperationException>().having(
          (e) => e.message,
          'message',
          assignedPackageMessage,
        ),
      ),
    );
  });

  test(
    'Database foreign-key conflict reports the assignment warning',
    () async {
      final repo = repository(
        (request) async => request.method == 'GET'
            ? http.Response('[]', 200)
            : http.Response(
                '{"code":"23503","message":"foreign key violation"}',
                409,
              ),
      );
      await expectLater(
        repo.deletePackage('assigned-during-confirmation'),
        throwsA(
          isA<PackageOperationException>().having(
            (e) => e.message,
            'message',
            assignedPackageMessage,
          ),
        ),
      );
    },
  );

  test(
    'Successful delete requires a returned row; denied writes are not reported as success',
    () async {
      var allow = false;
      final repo = repository((request) async {
        if (request.method == 'GET') return http.Response('[]', 200);
        if (request.method == 'DELETE' && allow) {
          return http.Response('[{"id":"free"}]', 200);
        }
        return http.Response('[]', 200);
      });
      await expectLater(
        repo.deletePackage('free'),
        throwsA(isA<PackageOperationException>()),
      );
      await expectLater(
        repo.savePackage(
          id: 'free',
          name: 'Edited',
          duration: '1 Month',
          price: 1,
          description: '',
          category: 'Monthly',
        ),
        throwsA(isA<PackageOperationException>()),
      );
      allow = true;
      await repo.deletePackage('free');
    },
  );
}
