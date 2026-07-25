import 'package:identity_server/src/auth/constants/auth_claim_names.dart';
import 'package:identity_server/src/auth/domain/auth_claims.dart';
import 'package:identity_server/src/auth/domain/authenticated_request.dart';
import 'package:identity_server/src/auth/routes/auth_dependencies.dart';
import 'package:identity_server/src/auth/routes/auth_me_route.dart';
import 'package:identity_server/src/generated/protocol.dart' as protocol;
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('AuthMeRoute', () {
    test('returns connected identity and session details', () async {
      final route = AuthMeRoute();
      final identityId = const Uuid().v7obj();
      final authSessionId = const Uuid().v7obj();
      final identity = protocol.Identity(
        id: identityId,
        username: 'noxe',
        email: 'noxe@example.com',
        emailVerified: true,
        status: protocol.IdentityStatus.active,
      );
      final authSession = protocol.AuthSession(
        id: authSessionId,
        identityId: identityId,
        expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
        authMethod: protocol.AuthProvider.username,
      );
      final claims = AuthClaims.access(
        identityId: identityId,
        sessionId: authSessionId,
        emailVerified: true,
        authenticationMethods: [protocol.AuthProvider.username],
      );

      final result = await route.executeAuthenticated(
        _FakeSession(),
        _FakeRequest(),
        _FakeAuthDependencies(),
        AuthenticatedRequest(
          identityId: identityId,
          authSessionId: authSessionId,
          claims: claims,
          identity: identity,
          authSession: authSession,
        ),
      );

      expect(result.responseBody(), {
        AuthClaimNames.subject: identityId.toString(),
        AuthClaimNames.sessionId: authSessionId.toString(),
        'identityId': identityId.toString(),
        'authSessionId': authSessionId.toString(),
        'username': 'noxe',
        'email': 'noxe@example.com',
        'emailVerified': true,
        AuthClaimNames.authenticationMethods: ['username'],
      });
    });
  });
}

class _FakeSession implements Session {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRequest implements Request {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthDependencies implements AuthDependencies {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
