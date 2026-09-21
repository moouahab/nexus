import 'package:identity_server/src/auth/application/exceptions/auth_use_case_exception.dart';
import 'package:identity_server/src/auth/application/services/service_token_issuer.dart';
import 'package:identity_server/src/auth/infrastructure/security/hmac_sha256_access_token_service.dart';
import 'package:identity_server/src/auth/infrastructure/security/static_service_client_registry.dart';
import 'package:nexus_auth/nexus_auth.dart' as nexus_auth;
import 'package:test/test.dart';

void main() {
  group('ServiceTokenIssuer', () {
    test('requires a matching Projects grant for project-bound tokens', () {
      final issuer = _issuer();
      const projectId = '018f0000-0000-7000-8000-000000000001';
      const identityId = '018f0000-0000-7000-8000-000000000002';
      const tenantId = '018f0000-0000-7000-8000-000000000003';
      final grant =
          const nexus_auth.ProjectAuthorizationGrantCodec(
            secret: 'project-grant-secret',
          ).issue(
            projectId: projectId,
            tenantPartyId: tenantId,
            identityId: identityId,
          );

      final result = issuer.issue(
        serviceName: 'ai-gateway',
        serviceSecret: 'ai-secret',
        audience: 'projects-service',
        scopes: ['projects.read'],
        projectId: projectId,
        delegatedIdentityId: identityId,
        authorizationGrant: grant,
        authorizationTenantPartyId: tenantId,
      );
      expect(result.projectId, projectId);

      expect(
        () => issuer.issue(
          serviceName: 'ai-gateway',
          serviceSecret: 'ai-secret',
          audience: 'projects-service',
          scopes: ['projects.read'],
          projectId: '018f0000-0000-7000-8000-000000000099',
          delegatedIdentityId: identityId,
          authorizationGrant: grant,
          authorizationTenantPartyId: tenantId,
        ),
        throwsA(anyOf(isA<AuthUseCaseException>(), isA<FormatException>())),
      );
      expect(
        () => issuer.issue(
          serviceName: 'ai-gateway',
          serviceSecret: 'ai-secret',
          audience: 'projects-service',
          scopes: ['projects.read'],
          projectId: projectId,
          delegatedIdentityId: identityId,
          authorizationGrant: grant,
          authorizationTenantPartyId: '018f0000-0000-7000-8000-000000000099',
        ),
        throwsA(isA<AuthUseCaseException>()),
      );
    });

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

    test('rejects ambiguous multiple resource boundaries', () {
      final issuer = _issuer();

      expect(
        () => issuer.issue(
          serviceName: 'projects',
          serviceSecret: 'projects-secret',
          audience: 'ai-gateway',
          scopes: ['ai.run.create'],
          tenantPartyId: 'tenant-a',
          projectId: 'project-a',
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
  },
  "ai-gateway": {
    "secret": "ai-secret",
    "audiences": ["projects-service"],
    "scopes": ["projects.read"]
  }
}
'''),
    tokenService: HmacSha256AccessTokenService(
      secret: 'token-signing-secret',
    ),
    projectGrantCodec: const nexus_auth.ProjectAuthorizationGrantCodec(
      secret: 'project-grant-secret',
    ),
  );
}
