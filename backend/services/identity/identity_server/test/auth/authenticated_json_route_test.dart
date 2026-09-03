import 'package:identity_server/src/auth/application/exceptions/authentication_required_exception.dart';
import 'package:identity_server/src/auth/domain/auth_result.dart';
import 'package:identity_server/src/auth/domain/auth_token_transport.dart';
import 'package:identity_server/src/auth/domain/authenticated_request.dart';
import 'package:identity_server/src/auth/routes/auth_dependencies.dart';
import 'package:identity_server/src/auth/routes/authenticated_json_route.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('AuthenticatedJsonRoute', () {
    test('maps missing or invalid authentication to 401', () {
      final route = _ProtectedRoute();

      for (final code in [
        AuthenticationRequiredExceptionCode.missingAccessToken,
        AuthenticationRequiredExceptionCode.invalidAccessToken,
        AuthenticationRequiredExceptionCode.sessionNotFound,
        AuthenticationRequiredExceptionCode.identityNotFound,
      ]) {
        final response = route.authenticationRequiredResponse(
          AuthenticationRequiredException(code),
        );

        expect(response.statusCode, 401);
      }
    });

    test('maps disabled identity to 403', () {
      final route = _ProtectedRoute();

      final response = route.authenticationRequiredResponse(
        const AuthenticationRequiredException(
          AuthenticationRequiredExceptionCode.identityNotActive,
        ),
      );

      expect(response.statusCode, 403);
    });

    test('rejects malformed JSON body fields before route execution', () {
      final route = _ProtectedRoute();

      expect(
        () => route.readStringBodyField({}, 'username'),
        throwsFormatException,
      );
      expect(
        () => route.readStringBodyField({'username': 123}, 'username'),
        throwsFormatException,
      );
      expect(
        route.readOptionalStringBodyField({'email': null}, 'email'),
        isNull,
      );
      expect(
        () => route.readOptionalStringBodyField({'email': 123}, 'email'),
        throwsFormatException,
      );
      expect(
        () =>
            route.readUuidBodyField({'identityId': 'not-a-uuid'}, 'identityId'),
        throwsFormatException,
      );
    });

    test('allows body token transport for non-browser requests', () {
      final route = _ProtectedRoute();

      expect(
        route.tokenTransport(
          _FakeRequest(
            headers: {
              'x-auth-token-transport': ['body'],
            },
          ),
        ),
        AuthTokenTransport.body,
      );
    });

    test('rejects body token transport from browser-like requests', () {
      final route = _ProtectedRoute();

      for (final headers in [
        {
          'x-auth-token-transport': ['body'],
          'origin': ['https://app.example.com'],
        },
        {
          'x-auth-token-transport': ['body'],
          'referer': ['https://app.example.com/login'],
        },
        {
          'x-auth-token-transport': ['body'],
          'sec-fetch-site': ['same-origin'],
        },
        {
          'x-auth-token-transport': ['body'],
          'cookie': ['csrf_token=value'],
        },
        {
          'origin': ['https://app.example.com'],
        },
      ]) {
        expect(
          () => route.tokenTransport(
            _FakeRequest(headers: headers),
            body: const {'tokenTransport': 'body'},
          ),
          throwsFormatException,
        );
      }
    });
  });
}

class _ProtectedRoute extends AuthenticatedJsonRoute {
  @override
  Future<AuthResult> executeAuthenticated(
    Session session,
    Request request,
    AuthDependencies dependencies,
    AuthenticatedRequest authenticated,
  ) {
    return Future.value(
      AuthResult(
        identityId: authenticated.identityId,
        authSessionId: authenticated.authSessionId,
        responseHeaders: const {},
      ),
    );
  }
}

class _FakeRequest implements Request {
  _FakeRequest({Map<String, List<String>> headers = const {}})
    : headers = Headers.fromMap(headers);

  @override
  final Headers headers;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
