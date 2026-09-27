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

        final unauthenticatedLogout = await client.postJson(
          '/auth/logout',
          {},
        );

        expect(unauthenticatedLogout.statusCode, 401);
        expect(unauthenticatedLogout.jsonBody, {
          'error': 'missingAccessToken',
        });

        final registered = await client.postJson('/auth/register', {
          'username': username,
          'password': password,
          'confirmPassword': password,
          'email': '$username@example.com',
        });

        expect(registered.statusCode, 200);
        expect(registered.jsonBody['identityId'], isA<String>());
        expect(registered.jsonBody['authSessionId'], isA<String>());
        expect(client.cookies, contains('access_token'));
        expect(client.cookies, contains('refresh_token'));
        expect(client.cookies, contains('csrf_token'));

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
        expect(client.cookies, contains('csrf_token'));

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
        expect(client.cookies, isNot(contains('csrf_token')));

        final meAfterLogout = await client.get('/auth/me');

        expect(meAfterLogout.statusCode, 401);
        expect(meAfterLogout.jsonBody, {
          'error': 'missingAccessToken',
        });
      },
    );

    test('supports body tokens and bearer auth for apps', () async {
      if (!runHttpTests) {
        expect(
          runHttpTests,
          isFalse,
          reason: 'Set IDENTITY_RUN_HTTP_TESTS=true to run HTTP auth flow.',
        );
        return;
      }

      final registered = await client.postJson(
        '/auth/register',
        {
          'username': username,
          'password': password,
          'confirmPassword': password,
          'email': '$username@example.com',
        },
        headers: const {
          'X-Auth-Token-Transport': 'body',
        },
      );

      expect(registered.statusCode, 200);
      expect(registered.jsonBody['identityId'], isA<String>());
      expect(registered.jsonBody['authSessionId'], isA<String>());
      expect(registered.jsonBody['tokenType'], 'Bearer');
      expect(registered.jsonBody['accessToken'], isA<String>());
      expect(registered.jsonBody['refreshToken'], isA<String>());
      expect(_jwtHeader(registered.jsonBody['accessToken'])['alg'], 'RS256');
      expect(
        _jwtHeader(registered.jsonBody['accessToken'])['kid'],
        'identity-access-token-current',
      );
      expect(client.cookies, isNot(contains('access_token')));
      expect(client.cookies, isNot(contains('refresh_token')));

      final bearerMe = await client.get(
        '/auth/me',
        headers: {
          'Authorization': 'Bearer ${registered.jsonBody['accessToken']}',
        },
      );

      expect(bearerMe.statusCode, 200);
      expect(
        bearerMe.jsonBody['identityId'],
        registered.jsonBody['identityId'],
      );
      expect(bearerMe.jsonBody['sid'], registered.jsonBody['authSessionId']);

      final refreshed = await client.postJson('/auth/refresh', {
        'refreshToken': registered.jsonBody['refreshToken'],
        'tokenTransport': 'body',
      });

      expect(refreshed.statusCode, 200);
      expect(
        refreshed.jsonBody['identityId'],
        registered.jsonBody['identityId'],
      );
      expect(refreshed.jsonBody['accessToken'], isA<String>());
      expect(refreshed.jsonBody['refreshToken'], isA<String>());
      expect(
        refreshed.jsonBody['refreshToken'],
        isNot(registered.jsonBody['refreshToken']),
      );

      final oldRefreshReuse = await client.postJson('/auth/refresh', {
        'refreshToken': registered.jsonBody['refreshToken'],
        'tokenTransport': 'body',
      });

      expect(oldRefreshReuse.statusCode, 401);
      expect(oldRefreshReuse.jsonBody, {
        'error': 'invalidRefreshToken',
      });
    });

    test('rejects auth requests from untrusted browser origins', () async {
      if (!runHttpTests) {
        expect(
          runHttpTests,
          isFalse,
          reason: 'Set IDENTITY_RUN_HTTP_TESTS=true to run HTTP auth flow.',
        );
        return;
      }

      final response = await client.postJson(
        '/auth/register',
        {
          'username': username,
          'password': password,
          'confirmPassword': password,
          'email': '$username@example.com',
        },
        headers: const {
          'Origin': 'https://evil.example',
        },
      );

      expect(response.statusCode, 400);
      expect(response.jsonBody, {
        'error': 'invalid_request',
      });
    });

    test('rejects password confirmation mismatch', () async {
      if (!runHttpTests) {
        expect(
          runHttpTests,
          isFalse,
          reason: 'Set IDENTITY_RUN_HTTP_TESTS=true to run HTTP auth flow.',
        );
        return;
      }

      final response = await client.postJson('/auth/register', {
        'username': username,
        'password': password,
        'confirmPassword': 'different-password-123',
        'email': '$username@example.com',
      });

      expect(response.statusCode, 400);
      expect(response.jsonBody, {
        'error': 'passwordConfirmationMismatch',
      });
    });
  });
}

Map<String, dynamic> _jwtHeader(Object? token) {
  final parts = (token as String).split('.');
  return (jsonDecode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[0]))),
          )
          as Map<String, dynamic>)
      .cast<String, dynamic>();
}

class _AuthHttpClient {
  _AuthHttpClient(this.baseUrl);

  final Uri baseUrl;
  final HttpClient _client = HttpClient();
  final Map<String, String> cookies = {};

  Future<_HttpResponse> get(
    String path, {
    Map<String, String> headers = const {},
  }) async {
    final request = await _open('GET', path);
    _setHeaders(request, headers);
    return _send(request);
  }

  Future<_HttpResponse> postJson(
    String path,
    Map<String, dynamic> body, {
    Map<String, String> headers = const {},
  }) async {
    final request = await _open('POST', path);
    request.headers.contentType = ContentType.json;
    _setHeaders(request, headers);
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

  void _setHeaders(HttpClientRequest request, Map<String, String> headers) {
    final csrfToken = cookies['csrf_token'];
    if (csrfToken != null && !headers.containsKey('X-CSRF-Token')) {
      request.headers.set('X-CSRF-Token', csrfToken);
    }

    for (final entry in headers.entries) {
      request.headers.set(entry.key, entry.value);
    }
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
