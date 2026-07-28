import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  final baseUrl = Uri.parse(
    Platform.environment['IDENTITY_HTTP_BASE_URL'] ?? 'http://127.0.0.1:8182',
  );
  final runHttpTests =
      Platform.environment['IDENTITY_RUN_HTTP_TESTS'] == 'true' ||
      Platform.environment['IDENTITY_HTTP_BASE_URL'] != null;

  group('Auth HTTP flow', () {
    late _AuthHttpClient client;
    late String username;
    const password = 'test-password-123';

    setUp(() {
      client = _AuthHttpClient(baseUrl);
      username = 'http_flow_${DateTime.now().microsecondsSinceEpoch}';
    });

    tearDown(() {
      client.close();
    });

    test(
      'registers, authenticates, refreshes, logs out and rejects bad requests',
      () async {
        if (!runHttpTests) {
          expect(
            runHttpTests,
            isFalse,
            reason: 'Set IDENTITY_RUN_HTTP_TESTS=true to run HTTP auth flow.',
          );
          return;
        }

        final unauthenticatedMe = await client.get('/auth/me');

        expect(unauthenticatedMe.statusCode, 401);
        expect(unauthenticatedMe.jsonBody, {
          'error': 'missingAccessToken',
        });

        final registered = await client.postJson('/auth/register', {
          'username': username,
          'password': password,
          'email': '$username@example.com',
        });

        expect(registered.statusCode, 200);
        expect(registered.jsonBody['identityId'], isA<String>());
        expect(registered.jsonBody['authSessionId'], isA<String>());
        expect(client.cookies, contains('access_token'));
        expect(client.cookies, contains('refresh_token'));

        final me = await client.get('/auth/me');

        expect(me.statusCode, 200);
        expect(me.jsonBody['identityId'], registered.jsonBody['identityId']);
        expect(
          me.jsonBody['authSessionId'],
          registered.jsonBody['authSessionId'],
        );
        expect(me.jsonBody['sub'], registered.jsonBody['identityId']);
        expect(me.jsonBody['sid'], registered.jsonBody['authSessionId']);
        expect(me.jsonBody['username'], username);
        expect(me.jsonBody['email'], '$username@example.com');
        expect(me.jsonBody['emailVerified'], isFalse);
        expect(me.jsonBody['amr'], ['username']);

        final badLoginClient = _AuthHttpClient(baseUrl);
        addTearDown(badLoginClient.close);

        final wrongPassword = await badLoginClient.postJson('/auth/login', {
          'username': username,
          'password': 'wrong-password',
        });

        expect(wrongPassword.statusCode, 401);
        expect(wrongPassword.jsonBody, {
          'error': 'invalidCredentials',
        });

        final tamperedClient = _AuthHttpClient(baseUrl)
          ..cookies['access_token'] = 'tampered.jwt.token';
        addTearDown(tamperedClient.close);

        final tamperedMe = await tamperedClient.get('/auth/me');

        expect(tamperedMe.statusCode, 401);
        expect(tamperedMe.jsonBody, {
          'error': 'invalidAccessToken',
        });

        final refreshed = await client.postJson('/auth/refresh', {});

        expect(refreshed.statusCode, 200);
        expect(
          refreshed.jsonBody['identityId'],
          registered.jsonBody['identityId'],
        );
        expect(
          refreshed.jsonBody['authSessionId'],
          registered.jsonBody['authSessionId'],
        );
        expect(client.cookies, contains('access_token'));
        expect(client.cookies, contains('refresh_token'));

        final meAfterRefresh = await client.get('/auth/me');

        expect(meAfterRefresh.statusCode, 200);
        expect(
          meAfterRefresh.jsonBody['identityId'],
          registered.jsonBody['identityId'],
        );

        final logout = await client.postJson('/auth/logout', {});

        expect(logout.statusCode, 200);
        expect(logout.jsonBody['identityId'], isNull);
        expect(
          logout.jsonBody['authSessionId'],
          registered.jsonBody['authSessionId'],
        );
        expect(client.cookies, isNot(contains('access_token')));
        expect(client.cookies, isNot(contains('refresh_token')));

        final meAfterLogout = await client.get('/auth/me');

        expect(meAfterLogout.statusCode, 401);
        expect(meAfterLogout.jsonBody, {
          'error': 'missingAccessToken',
        });
      },
    );
  });
}

class _AuthHttpClient {
  _AuthHttpClient(this.baseUrl);

  final Uri baseUrl;
  final HttpClient _client = HttpClient();
  final Map<String, String> cookies = {};

  Future<_HttpResponse> get(String path) async {
    final request = await _open('GET', path);
    return _send(request);
  }

  Future<_HttpResponse> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final request = await _open('POST', path);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    return _send(request);
  }

  void close() {
    _client.close(force: true);
  }

  Future<HttpClientRequest> _open(String method, String path) async {
    final request = await _client.openUrl(method, baseUrl.resolve(path));

    if (cookies.isNotEmpty) {
      request.headers.set(
        HttpHeaders.cookieHeader,
        cookies.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join('; '),
      );
    }

    return request;
  }

  Future<_HttpResponse> _send(HttpClientRequest request) async {
    final response = await request.close();
    _storeResponseCookies(response);

    final rawBody = await utf8.decoder.bind(response).join();
    final decoded = rawBody.isEmpty ? <String, dynamic>{} : jsonDecode(rawBody);

    return _HttpResponse(
      statusCode: response.statusCode,
      jsonBody: decoded as Map<String, dynamic>,
    );
  }

  void _storeResponseCookies(HttpClientResponse response) {
    for (final cookie in response.cookies) {
      if (cookie.maxAge == 0 || cookie.value.isEmpty) {
        cookies.remove(cookie.name);
      } else {
        cookies[cookie.name] = cookie.value;
      }
    }
  }
}

class _HttpResponse {
  const _HttpResponse({
    required this.statusCode,
    required this.jsonBody,
  });

  final int statusCode;
  final Map<String, dynamic> jsonBody;
}
