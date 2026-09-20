import 'package:identity_server/src/auth/application/exceptions/auth_use_case_exception.dart';
import 'package:identity_server/src/auth/application/services/service_token_issuer.dart';
import 'package:identity_server/src/auth/infrastructure/security/hmac_sha256_access_token_service.dart';
import 'package:identity_server/src/auth/infrastructure/security/static_service_client_registry.dart';
import 'package:nexus_auth/nexus_auth.dart' as nexus_auth;
import 'package:test/test.dart';

void main() {
  group('ServiceTokenIssuer', () {
    test('issues scoped service tokens for registered clients', () {
      final issuer = _issuer();

      final result = issuer.issue(
        serviceName: 'projects',
        serviceSecret: 'projects-secret',
        audience: 'ai-gateway',
        scopes: ['ai.run.create', 'ai.context.preview'],
        tenantPartyId: 'tenant-a',
      );

      final context =
          nexus_auth.HmacSha256AccessTokenVerifier(
            secret: 'token-signing-secret',
            audience: 'ai-gateway',
          ).verifyServiceToken(
            result.accessToken,
            requiredScopes: ['ai.context.preview'],
          );

      expect(result.serviceName, 'projects');
      expect(result.audience, 'ai-gateway');
      expect(result.scopes, ['ai.context.preview', 'ai.run.create']);
      expect(context.serviceName, 'projects');
      expect(context.tenantPartyId, 'tenant-a');
      expect(context.globalAccess, isFalse);
    });

    test('rejects unknown service and wrong secret', () {
      final issuer = _issuer();

      expect(
        () => issuer.issue(
          serviceName: 'missing',
          serviceSecret: 'projects-secret',
          audience: 'ai-gateway',
          scopes: ['ai.run.create'],
        ),
        throwsA(isA<AuthUseCaseException>()),
      );
      expect(
        () => issuer.issue(
          serviceName: 'projects',
          serviceSecret: 'wrong-secret',
          audience: 'ai-gateway',
          scopes: ['ai.run.create'],
        ),
        throwsA(isA<AuthUseCaseException>()),
      );
    });

    test('rejects unauthorized audience or scope', () {
      final issuer = _issuer();

      expect(
        () => issuer.issue(
          serviceName: 'projects',
          serviceSecret: 'projects-secret',
          audience: 'projects-service',
          scopes: ['ai.run.create'],
        ),
        throwsA(isA<AuthUseCaseException>()),
      );
      expect(
        () => issuer.issue(
          serviceName: 'projects',
          serviceSecret: 'projects-secret',
          audience: 'ai-gateway',
          scopes: ['ai.run.cancel'],
        ),
        throwsA(isA<AuthUseCaseException>()),
      );
    });

    test('rejects unbounded tokens unless registration opts into global', () {
      final issuer = _issuer();

      expect(
        () => issuer.issue(
          serviceName: 'projects',
          serviceSecret: 'projects-secret',
          audience: 'ai-gateway',
          scopes: ['ai.run.create'],
        ),
        throwsA(isA<AuthUseCaseException>()),
      );
      expect(
        () => issuer.issue(
          serviceName: 'projects',
          serviceSecret: 'projects-secret',
          audience: 'ai-gateway',
          scopes: ['ai.run.create'],
          globalAccess: true,
        ),
        throwsA(isA<AuthUseCaseException>()),
      );
    });
  });
}

ServiceTokenIssuer _issuer() {
  return ServiceTokenIssuer(
    clientRegistry: StaticServiceClientRegistry.fromJson('''
{
  "projects": {
    "secret": "projects-secret",
    "audiences": ["ai-gateway"],
    "scopes": ["ai.context.preview", "ai.run.create"]
  }
}
'''),
    tokenService: HmacSha256AccessTokenService(
      secret: 'token-signing-secret',
    ),
  );
}
