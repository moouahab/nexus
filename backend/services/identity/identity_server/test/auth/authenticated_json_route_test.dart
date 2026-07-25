import 'package:identity_server/src/auth/application/exceptions/authentication_required_exception.dart';
import 'package:identity_server/src/auth/domain/auth_result.dart';
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
