import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cardsnap/core/auth/auth_service.dart';
import 'package:cardsnap/core/auth/rbac_client.dart';
import 'package:cardsnap/core/database/database.dart';
import 'package:cardsnap/core/marketing/marketing_client.dart';
import 'package:cardsnap/core/marketing/marketing_models.dart';
import 'package:cardsnap/core/marketing/marketing_sync_service.dart';
import 'package:cardsnap/core/models/contact.dart' as model;

class _MemStore implements SessionStore {
  String? value;
  _MemStore([this.value]);
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String v) async => value = v;
  @override
  Future<void> delete() async => value = null;
}

model.Contact _contact({String id = 'c1', String name = 'Rohan Mehta'}) => model.Contact(
      id: id,
      name: name,
      company: 'Larsen & Toubro Ltd',
      phones: const ['+91-98765-33201'],
      emails: const ['rohan.mehta@lnt.com'],
      linkedInUrl: 'https://linkedin.com/in/rohan',
      confidence: const {},
      parseMode: 'local',
      createdAt: DateTime(2026, 1, 1),
    );

AuthService _authWith(String token, {http.Client? rbac}) {
  final client = RbacClient(
    httpClient: rbac ?? MockClient((r) async => http.Response(jsonEncode(['a.b']), 200)),
    baseUrl: 'https://hrms.test',
  );
  final svc = AuthService(
    client: client,
    store: _MemStore(jsonEncode({
      'token': token,
      'user': {'username': 'rohan'},
      'employee': {},
      'roles': [],
      'permissions': ['x'],
    })),
  );
  return svc;
}

void main() {
  late AppDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  test('buildPayload maps a contact to the API shape', () {
    final p = MarketingSyncService.buildPayload(_contact());
    expect(p['name'], 'Rohan Mehta');
    expect(p['company_name'], 'Larsen & Toubro Ltd');
    expect(p['phone_numbers'], ['+91-98765-33201']);
    expect(p['emails'], ['rohan.mehta@lnt.com']);
    expect(p['social_media'], ['https://linkedin.com/in/rohan']);
    expect(p['source'], 'card-scanner-app');
    expect(p.containsKey('domain_id'), isFalse);
    expect(p.containsKey('organization_id'), isFalse);
  });

  test('successful push clears the queue and stamps the contact', () async {
    await db.contactsDao.insertContact(_contact());
    final auth = _authWith('jwt-1');
    await auth.restore();

    String? sentAuthHeader;
    final marketing = MarketingClient(
      baseUrl: 'http://localhost:8003',
      httpClient: MockClient((req) async {
        sentAuthHeader = req.headers['Authorization'];
        return http.Response(jsonEncode({'id': 77, 'name': 'Rohan Mehta'}), 201);
      }),
    );
    final sync = MarketingSyncService(db: db, auth: auth, client: marketing);

    await sync.enqueue(_contact());
    await sync.flush();
    await pumpEventQueue();

    expect(sentAuthHeader, 'Bearer jwt-1');
    expect(sync.pendingCount, 0);
    expect(sync.failedCount, 0);
    final c = await db.contactsDao.getContactById('c1');
    expect(c!.marketingContactId, 77);
  });

  test('403 marks the item failed with the permission message', () async {
    final auth = _authWith('jwt-1');
    await auth.restore();
    final sync = MarketingSyncService(
      db: db,
      auth: auth,
      client: MarketingClient(
        baseUrl: 'http://localhost:8003',
        httpClient: MockClient((req) async => http.Response('{"detail":"no perm"}', 403)),
      ),
    );

    await sync.enqueue(_contact());
    await sync.flush();
    await pumpEventQueue();

    expect(sync.pendingCount, 0);
    expect(sync.failedCount, 1);
    expect(sync.failures.first.error, 'no perm');
  });

  test('422 marks failed and keeps other rows workable', () async {
    final auth = _authWith('jwt-1');
    await auth.restore();
    final sync = MarketingSyncService(
      db: db,
      auth: auth,
      client: MarketingClient(
        baseUrl: 'http://localhost:8003',
        httpClient: MockClient((req) async =>
            http.Response(jsonEncode({'phone_numbers': ['invalid']}), 422)),
      ),
    );

    await sync.enqueue(_contact());
    await sync.flush();
    await pumpEventQueue();

    expect(sync.failedCount, 1);
    expect(sync.failures.first.error, contains('phone_numbers'));
  });

  test('network error leaves the item pending for later retry', () async {
    final auth = _authWith('jwt-1');
    await auth.restore();
    final sync = MarketingSyncService(
      db: db,
      auth: auth,
      client: MarketingClient(
        baseUrl: 'http://localhost:8003',
        httpClient: MockClient((req) async => throw Exception('no network')),
      ),
    );

    await sync.enqueue(_contact());
    await sync.flush();
    await pumpEventQueue();

    expect(sync.pendingCount, 1);
    expect(sync.failedCount, 0);
  });

  test('401 then a valid token: re-auth and the retry succeeds', () async {
    // RBAC says the token is still fine, so revalidate() returns true.
    final auth = _authWith('jwt-1',
        rbac: MockClient((r) async => http.Response(jsonEncode(['perm.a']), 200)));
    await auth.restore();

    var calls = 0;
    final sync = MarketingSyncService(
      db: db,
      auth: auth,
      client: MarketingClient(
        baseUrl: 'http://localhost:8003',
        httpClient: MockClient((req) async {
          calls++;
          if (calls == 1) return http.Response('{"detail":"expired"}', 401);
          return http.Response(jsonEncode({'id': 5}), 201);
        }),
      ),
    );

    await sync.enqueue(_contact());
    await sync.flush();
    await pumpEventQueue();

    expect(calls, 2);
    expect(sync.pendingCount, 0);
    expect(sync.failedCount, 0);
  });

  test('401 with a dead token: session cleared, item stays pending', () async {
    final auth = _authWith('jwt-1',
        rbac: MockClient((r) async => http.Response('{"detail":"bad"}', 401)));
    await auth.restore();

    final sync = MarketingSyncService(
      db: db,
      auth: auth,
      client: MarketingClient(
        baseUrl: 'http://localhost:8003',
        httpClient: MockClient((req) async => http.Response('{"detail":"expired"}', 401)),
      ),
    );

    await sync.enqueue(_contact());
    await sync.flush();
    await pumpEventQueue();

    expect(auth.status, AuthStatus.unauthenticated);
    expect(sync.pendingCount, 1); // survives for the next login
  });

  test('already-synced contact is not re-enqueued', () async {
    final auth = _authWith('jwt-1');
    await auth.restore();
    final sync = MarketingSyncService(
      db: db,
      auth: auth,
      client: MarketingClient(
        baseUrl: 'http://localhost:8003',
        httpClient: MockClient((req) async => http.Response(jsonEncode({'id': 1}), 201)),
      ),
    );

    await sync.enqueue(_contact().copyWith(marketingContactId: 99));
    expect(sync.pendingCount, 0);
  });

  test('a picked exhibition rides along in the payload notes', () {
    final c = _contact().copyWith(exhibitionName: 'ELECRAMA 2026', notes: 'talk to sales');
    final p = MarketingSyncService.buildPayload(c);
    expect(p['notes'], 'Exhibition: ELECRAMA 2026\n\ntalk to sales');
    expect(p.containsKey('exhibition_id'), isFalse);
  });

  group('reference data (save screen)', () {
    test('loadCaptureContext returns scope + domain-filtered exhibitions', () async {
      final auth = _authWith('jwt-1');
      await auth.restore();
      final sync = MarketingSyncService(
        db: db,
        auth: auth,
        client: MarketingClient(
          baseUrl: 'http://localhost:8003',
          httpClient: MockClient((req) async {
            if (req.url.path == '/api/auth/scope') {
              return http.Response(
                  jsonEncode({'success': true, 'domain_id': 3, 'region_id': 7, 'role': 'region_head'}),
                  200);
            }
            if (req.url.path == '/api/exhibitions/active') {
              expect(req.headers['Authorization'], 'Bearer jwt-1');
              return http.Response(
                  jsonEncode([
                    {'id': 12, 'name': 'ELECRAMA 2026', 'location': 'Mumbai', 'domain_id': 3},
                    {'id': 20, 'name': 'Other Domain Expo', 'domain_id': 9},
                  ]),
                  200);
            }
            return http.Response('nope', 404);
          }),
        ),
      );

      final ctx = await sync.loadCaptureContext();
      expect(ctx.scope!.domainId, 3);
      expect(ctx.scope!.regionId, 7);
      expect(ctx.exhibitions.length, 2);
      // nothing hidden; the employee's own domain (3) sorts first
      expect(ctx.exhibitionsForEmployeeDomain.map((e) => e.id), [12, 20]);
      expect(ctx.exhibitionsError, isNull);
    });

    test('exhibitions 403 → error surfaced, scope still loads', () async {
      final auth = _authWith('jwt-1');
      await auth.restore();
      final sync = MarketingSyncService(
        db: db,
        auth: auth,
        client: MarketingClient(
          baseUrl: 'http://localhost:8003',
          httpClient: MockClient((req) async {
            if (req.url.path == '/api/auth/scope') {
              return http.Response(jsonEncode({'domain_id': 3}), 200);
            }
            return http.Response('{"detail":"forbidden"}', 403);
          }),
        ),
      );

      final ctx = await sync.loadCaptureContext();
      expect(ctx.scope!.domainId, 3);
      expect(ctx.exhibitions, isEmpty);
      expect(ctx.exhibitionsError, 'forbidden');
    });

    test('active exhibition persists and reloads', () async {
      final prefs = await SharedPreferences.getInstance();
      final auth = _authWith('jwt-1');
      final s1 = MarketingSyncService(
        db: db, auth: auth, prefs: prefs,
        client: MarketingClient(baseUrl: 'http://localhost:8003'),
      );
      await s1.setActiveExhibition(
          const Exhibition(id: 12, name: 'ELECRAMA 2026', location: 'Mumbai', domainId: 3));
      expect(s1.activeExhibition?.id, 12);

      // A fresh service reads it back from prefs.
      final s2 = MarketingSyncService(
        db: db, auth: auth, prefs: prefs,
        client: MarketingClient(baseUrl: 'http://localhost:8003'),
      );
      await pumpEventQueue();
      expect(s2.activeExhibition?.name, 'ELECRAMA 2026');

      await s2.setActiveExhibition(null);
      final s3 = MarketingSyncService(
        db: db, auth: auth, prefs: prefs,
        client: MarketingClient(baseUrl: 'http://localhost:8003'),
      );
      await pumpEventQueue();
      expect(s3.activeExhibition, isNull);
    });

    test('exhibitions list is cached between calls', () async {
      final auth = _authWith('jwt-1');
      await auth.restore();
      var exhibitionCalls = 0;
      final sync = MarketingSyncService(
        db: db,
        auth: auth,
        client: MarketingClient(
          baseUrl: 'http://localhost:8003',
          httpClient: MockClient((req) async {
            if (req.url.path == '/api/exhibitions/active') {
              exhibitionCalls++;
              return http.Response(jsonEncode([
                {'id': 1, 'name': 'A', 'domain_id': 3}
              ]), 200);
            }
            return http.Response(jsonEncode({'domain_id': 3}), 200);
          }),
        ),
      );

      await sync.loadCaptureContext();
      await sync.loadCaptureContext();
      expect(exhibitionCalls, 1);
    });
  });
}
