import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:cardsnap/core/auth/auth_service.dart';
import 'package:cardsnap/core/auth/rbac_client.dart';

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

RbacClient _client(http.Client c) =>
    RbacClient(httpClient: c, baseUrl: 'https://hrms.test');

void main() {
  group('RbacClient.login — defensive parsing', () {
    test('happy path returns token + permission codes', () async {
      final mock = MockClient((req) async => http.Response(
            jsonEncode({
              'success': true,
              'token': 'abc123',
              'user': {'username': 'jdoe'},
              'employee': {'employee_id': 'E42'},
              'roles': ['Manager'],
              'permissions': ['employee.view', 'employee.add'],
            }),
            200,
          ));
      final r = await _client(mock).login('jdoe', 'pw');
      expect(r.token, 'abc123');
      expect(r.permissions, containsAll(['employee.view', 'employee.add']));
    });

    test('401 throws RbacUnauthorized with the API error text', () async {
      final mock = MockClient((req) async =>
          http.Response(jsonEncode({'success': false, 'error': 'Bad creds'}), 401));
      expect(
          () => _client(mock).login('x', 'y'),
          throwsA(isA<RbacUnauthorized>()
              .having((e) => e.message, 'message', 'Bad creds')));
    });

    test('200 with success:false is unauthorized', () async {
      final mock = MockClient((req) async =>
          http.Response(jsonEncode({'success': false, 'error': 'nope'}), 200));
      expect(() => _client(mock).login('x', 'y'), throwsA(isA<RbacUnauthorized>()));
    });

    test('200 with empty body is unauthorized', () async {
      final mock = MockClient((req) async => http.Response('', 200));
      expect(() => _client(mock).login('x', 'y'), throwsA(isA<RbacUnauthorized>()));
    });

    test('200 with token missing is unauthorized', () async {
      final mock = MockClient((req) async =>
          http.Response(jsonEncode({'success': true, 'user': {}}), 200));
      expect(() => _client(mock).login('x', 'y'), throwsA(isA<RbacUnauthorized>()));
    });

    test('transport failure throws RbacNetworkError', () async {
      final mock = MockClient((req) async => throw Exception('socket'));
      expect(() => _client(mock).login('x', 'y'), throwsA(isA<RbacNetworkError>()));
    });
  });

  group('RbacClient.permissionsList — token probe', () {
    test('bare JSON array of strings', () async {
      final mock = MockClient((req) async =>
          http.Response(jsonEncode(['employee.view', 'contact.add']), 200));
      expect(await _client(mock).permissionsList('tok'),
          ['employee.view', 'contact.add']);
    });

    test('empty body → unauthorized (not silently OK)', () async {
      final mock = MockClient((req) async => http.Response('', 200));
      expect(() => _client(mock).permissionsList('tok'),
          throwsA(isA<RbacUnauthorized>()));
    });

    test('unexpected object shape → unauthorized', () async {
      final mock = MockClient((req) async => http.Response(jsonEncode({'ok': 1}), 200));
      expect(() => _client(mock).permissionsList('tok'),
          throwsA(isA<RbacUnauthorized>()));
    });

    test('403 → unauthorized', () async {
      final mock = MockClient((req) async => http.Response('{}', 403));
      expect(() => _client(mock).permissionsList('tok'),
          throwsA(isA<RbacUnauthorized>()));
    });

    test('sends Authorization: Token <token>', () async {
      String? seen;
      final mock = MockClient((req) async {
        seen = req.headers['Authorization'];
        return http.Response(jsonEncode(['a.b']), 200);
      });
      await _client(mock).permissionsList('xyz');
      expect(seen, 'Token xyz');
    });
  });

  group('AuthService', () {
    test('successful login persists the session', () async {
      final mock = MockClient((req) async => http.Response(
            jsonEncode({
              'success': true,
              'token': 't0k',
              'user': {'username': 'jdoe'},
              'employee': {},
              'roles': [],
              'permissions': ['employee.view'],
            }),
            200,
          ));
      final store = _MemStore();
      final svc = AuthService(client: _client(mock), store: store);
      final err = await svc.login('jdoe', 'pw');
      expect(err, isNull);
      expect(svc.isAuthenticated, isTrue);
      expect(svc.hasPermission('employee.view'), isTrue);
      expect(store.value, isNotNull);
    });

    test('bad credentials surface the API error, no session', () async {
      final mock = MockClient((req) async =>
          http.Response(jsonEncode({'success': false, 'error': 'Invalid'}), 401));
      final svc = AuthService(client: _client(mock), store: _MemStore());
      expect(await svc.login('x', 'y'), 'Invalid');
      expect(svc.isAuthenticated, isFalse);
    });

    test('restore with a rejected token clears the session', () async {
      final store = _MemStore(jsonEncode({
        'token': 'stale',
        'user': {},
        'employee': {},
        'roles': [],
        'permissions': ['employee.view'],
      }));
      final mock = MockClient((req) async =>
          http.Response('{"detail":"bad token"}', 401));
      final svc = AuthService(client: _client(mock), store: store);
      await svc.restore();
      expect(svc.status, AuthStatus.unauthenticated);
      expect(store.value, isNull);
    });

    test('restore stays authenticated (offline) on a network error', () async {
      final store = _MemStore(jsonEncode({
        'token': 'good',
        'user': {'username': 'jdoe'},
        'employee': {},
        'roles': [],
        'permissions': ['employee.view'],
      }));
      final mock = MockClient((req) async => throw Exception('no network'));
      final svc = AuthService(client: _client(mock), store: store);
      await svc.restore();
      expect(svc.isAuthenticated, isTrue);
      expect(svc.isOffline, isTrue);
      expect(svc.hasPermission('employee.view'), isTrue);
    });

    test('restore with an unexpected empty response clears the session', () async {
      final store = _MemStore(jsonEncode({
        'token': 'good',
        'user': {},
        'employee': {},
        'roles': [],
        'permissions': [],
      }));
      final mock = MockClient((req) async => http.Response('', 200));
      final svc = AuthService(client: _client(mock), store: store);
      await svc.restore();
      expect(svc.status, AuthStatus.unauthenticated);
    });
  });
}
