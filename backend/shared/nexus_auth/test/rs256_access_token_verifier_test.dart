import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('Rs256AccessTokenVerifier', () {
    test('verifies access token with public key pem', () {
      final identityId = const Uuid().v7obj();
      final sessionId = const Uuid().v7obj();
      final token = _accessToken(identityId: identityId, sessionId: sessionId);

      final context = Rs256AccessTokenVerifier(
        publicKeyPem: _rsaPublicKeyPem,
      ).verify(token);

      expect(context.identityId, identityId);
      expect(context.authSessionId, sessionId);
      expect(context.emailVerified, isTrue);
      expect(context.authenticationMethods, ['username']);
    });

    test('verifies access token from jwks and key id', () {
      final identityId = const Uuid().v7obj();
      final sessionId = const Uuid().v7obj();
      final token = _accessToken(identityId: identityId, sessionId: sessionId);
      final jwks = {
        'keys': [
          RSAPublicKey(_rsaPublicKeyPem).toJWK(
            keyID: 'identity-access-token-current',
            algorithm: JWTAlgorithm.RS256,
          ),
        ],
      };

      final context = Rs256AccessTokenVerifier.fromJwks(
        jwks: jwks,
        keyId: 'identity-access-token-current',
      ).verify(token);

      expect(context.identityId, identityId);
    });

    test('rejects token with wrong public key', () {
      final token = _accessToken(
        identityId: const Uuid().v7obj(),
        sessionId: const Uuid().v7obj(),
      );

      expect(
        () => Rs256AccessTokenVerifier(
          publicKeyPem: _otherRsaPublicKeyPem,
        ).verify(token),
        throwsA(isA<NexusAuthException>()),
      );
    });

    test('verifies service token audience and required scopes', () {
      final token = _serviceToken(
        serviceName: 'projects',
        audience: 'users-service',
        scopes: ['users.profile.read', 'parties.membership.read'],
      );

      final context = Rs256AccessTokenVerifier(
        publicKeyPem: _rsaPublicKeyPem,
        audience: 'users-service',
      ).verifyServiceToken(token, requiredScopes: ['users.profile.read']);

      expect(context.serviceName, 'projects');
      expect(context.audiences, ['users-service']);
      expect(context.scopes, ['users.profile.read', 'parties.membership.read']);
    });

    test('rejects service token when verifying user access token', () {
      final token = _serviceToken(
        serviceName: 'projects',
        audience: AuthTokenDefaults.audience,
        scopes: ['projects.read'],
      );

      expect(
        () => Rs256AccessTokenVerifier(
          publicKeyPem: _rsaPublicKeyPem,
        ).verify(token),
        throwsA(isA<NexusAuthException>()),
      );
    });

    test('rejects service tokens presented to another Nexus audience', () {
      final aiToken = _serviceToken(
        serviceName: 'worker',
        audience: 'ai-gateway',
        scopes: ['ai.run.create'],
      );
      final projectsToken = _serviceToken(
        serviceName: 'ai-gateway',
        audience: 'projects-service',
        scopes: ['projects.read'],
      );

      expect(
        () => Rs256AccessTokenVerifier(
          publicKeyPem: _rsaPublicKeyPem,
          audience: 'projects-service',
        ).verifyServiceToken(aiToken, requiredScopes: ['projects.write']),
        throwsA(isA<NexusAuthException>()),
      );
      expect(
        () => Rs256AccessTokenVerifier(
          publicKeyPem: _rsaPublicKeyPem,
          audience: 'ai-gateway',
        ).verifyServiceToken(projectsToken, requiredScopes: ['ai.run.read']),
        throwsA(isA<NexusAuthException>()),
      );
    });

    test('rejects expired service tokens and missing scopes', () {
      final expired = _serviceToken(
        serviceName: 'worker',
        audience: 'ai-gateway',
        scopes: ['ai.run.read'],
        expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      );
      final createOnly = _serviceToken(
        serviceName: 'worker',
        audience: 'ai-gateway',
        scopes: ['ai.run.create'],
      );
      final verifier = Rs256AccessTokenVerifier(
        publicKeyPem: _rsaPublicKeyPem,
        audience: 'ai-gateway',
      );

      expect(
        () => verifier.verifyServiceToken(expired),
        throwsA(isA<NexusAuthException>()),
      );
      expect(
        () => verifier.verifyServiceToken(
          createOnly,
          requiredScopes: ['ai.run.read'],
        ),
        throwsA(isA<NexusAuthException>()),
      );
      expect(
        () => verifier.verifyServiceToken(
          createOnly,
          requiredScopes: ['ai.run.cancel'],
        ),
        throwsA(isA<NexusAuthException>()),
      );
    });

    test('rejects service tokens from an untrusted issuer', () {
      final token = _serviceToken(
        serviceName: 'worker',
        audience: 'projects-service',
        scopes: ['projects.read'],
        issuer: 'https://attacker.invalid',
      );

      expect(
        () => Rs256AccessTokenVerifier(
          publicKeyPem: _rsaPublicKeyPem,
          audience: 'projects-service',
        ).verifyServiceToken(token, requiredScopes: ['projects.read']),
        throwsA(isA<NexusAuthException>()),
      );
    });
  });
}

String _accessToken({
  required UuidValue identityId,
  required UuidValue sessionId,
}) {
  final now = DateTime.now().toUtc();
  return JWT(
    {
      AuthClaimNames.subject: identityId.toString(),
      AuthClaimNames.sessionId: sessionId.toString(),
      AuthClaimNames.issuer: AuthTokenDefaults.issuer,
      AuthClaimNames.audience: AuthTokenDefaults.audience,
      AuthClaimNames.tokenType: AuthTokenTypes.access,
      AuthClaimNames.issuedAt: now.millisecondsSinceEpoch ~/ 1000,
      AuthClaimNames.expiresAt:
          now.add(const Duration(minutes: 15)).millisecondsSinceEpoch ~/ 1000,
      AuthClaimNames.emailVerified: true,
      AuthClaimNames.authenticationMethods: ['username'],
    },
    header: {'kid': 'identity-access-token-current'},
  ).sign(
    RSAPrivateKey(_rsaPrivateKeyPem),
    algorithm: JWTAlgorithm.RS256,
    noIssueAt: true,
  );
}

String _serviceToken({
  required String serviceName,
  required String audience,
  required List<String> scopes,
  String issuer = AuthTokenDefaults.issuer,
  DateTime? expiresAt,
}) {
  final now = DateTime.now().toUtc();
  return JWT(
    {
      AuthClaimNames.subject: 'service:$serviceName',
      AuthClaimNames.issuer: issuer,
      AuthClaimNames.audience: audience,
      AuthClaimNames.tokenType: AuthTokenTypes.service,
      AuthClaimNames.issuedAt: now.millisecondsSinceEpoch ~/ 1000,
      AuthClaimNames.expiresAt:
          (expiresAt ?? now.add(const Duration(minutes: 5)))
              .millisecondsSinceEpoch ~/
          1000,
      AuthClaimNames.scopes: scopes,
    },
    header: {'kid': 'identity-access-token-current'},
  ).sign(
    RSAPrivateKey(_rsaPrivateKeyPem),
    algorithm: JWTAlgorithm.RS256,
    noIssueAt: true,
  );
}

const _rsaPrivateKeyPem = '''
-----BEGIN PRIVATE KEY-----
MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC7VJTUt9Us8cKj
MzEfYyjiWA4R4/M2bS1GB4t7NXp98C3SC6dVMvDuictGeurT8jNbvJZHtCSuYEvu
NMoSfm76oqFvAp8Gy0iz5sxjZmSnXyCdPEovGhLa0VzMaQ8s+CLOyS56YyCFGeJZ
qgtzJ6GR3eqoYSW9b9UMvkBpZODSctWSNGj3P7jRFDO5VoTwCQAWbFnOjDfH5Ulg
p2PKSQnSJP3AJLQNFNe7br1XbrhV//eO+t51mIpGSDCUv3E0DDFcWDTH9cXDTTlR
ZVEiR2BwpZOOkE/Z0/BVnhZYL71oZV34bKfWjQIt6V/isSMahdsAASACp4ZTGtwi
VuNd9tybAgMBAAECggEBAKTmjaS6tkK8BlPXClTQ2vpz/N6uxDeS35mXpqasqskV
laAidgg/sWqpjXDbXr93otIMLlWsM+X0CqMDgSXKejLS2jx4GDjI1ZTXg++0AMJ8
sJ74pWzVDOfmCEQ/7wXs3+cbnXhKriO8Z036q92Qc1+N87SI38nkGa0ABH9CN83H
mQqt4fB7UdHzuIRe/me2PGhIq5ZBzj6h3BpoPGzEP+x3l9YmK8t/1cN0pqI+dQwY
dgfGjackLu/2qH80MCF7IyQaseZUOJyKrCLtSD/Iixv/hzDEUPfOCjFDgTpzf3cw
ta8+oE4wHCo1iI1/4TlPkwmXx4qSXtmw4aQPz7IDQvECgYEA8KNThCO2gsC2I9PQ
DM/8Cw0O983WCDY+oi+7JPiNAJwv5DYBqEZB1QYdj06YD16XlC/HAZMsMku1na2T
N0driwenQQWzoev3g2S7gRDoS/FCJSI3jJ+kjgtaA7Qmzlgk1TxODN+G1H91HW7t
0l7VnL27IWyYo2qRRK3jzxqUiPUCgYEAx0oQs2reBQGMVZnApD1jeq7n4MvNLcPv
t8b/eU9iUv6Y4Mj0Suo/AU8lYZXm8ubbqAlwz2VSVunD2tOplHyMUrtCtObAfVDU
AhCndKaA9gApgfb3xw1IKbuQ1u4IF1FJl3VtumfQn//LiH1B3rXhcdyo3/vIttEk
48RakUKClU8CgYEAzV7W3COOlDDcQd935DdtKBFRAPRPAlspQUnzMi5eSHMD/ISL
DY5IiQHbIH83D4bvXq0X7qQoSBSNP7Dvv3HYuqMhf0DaegrlBuJllFVVq9qPVRnK
xt1Il2HgxOBvbhOT+9in1BzA+YJ99UzC85O0Qz06A+CmtHEy4aZ2kj5hHjECgYEA
mNS4+A8Fkss8Js1RieK2LniBxMgmYml3pfVLKGnzmng7H2+cwPLhPIzIuwytXywh
2bzbsYEfYx3EoEVgMEpPhoarQnYPukrJO4gwE2o5Te6T5mJSZGlQJQj9q4ZB2Dfz
et6INsK0oG8XVGXSpQvQh3RUYekCZQkBBFcpqWpbIEsCgYAnM3DQf3FJoSnXaMhr
VBIovic5l0xFkEHskAjFTevO86Fsz1C2aSeRKSqGFoOQ0tmJzBEs1R6KqnHInicD
TQrKhArgLXX4v3CddjfTRJkFWDbE/CkvKZNOrcf1nhaGCPspRJj2KUkj1Fhl9Cnc
dn/RsYEONbwQSjIfMPkvxF+8HQ==
-----END PRIVATE KEY-----
''';

const _rsaPublicKeyPem = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu1SU1LfVLPHCozMxH2Mo
4lgOEePzNm0tRgeLezV6ffAt0gunVTLw7onLRnrq0/IzW7yWR7QkrmBL7jTKEn5u
+qKhbwKfBstIs+bMY2Zkp18gnTxKLxoS2tFczGkPLPgizskuemMghRniWaoLcyeh
kd3qqGElvW/VDL5AaWTg0nLVkjRo9z+40RQzuVaE8AkAFmxZzow3x+VJYKdjykkJ
0iT9wCS0DRTXu269V264Vf/3jvredZiKRkgwlL9xNAwxXFg0x/XFw005UWVRIkdg
cKWTjpBP2dPwVZ4WWC+9aGVd+Gyn1o0CLelf4rEjGoXbAAEgAqeGUxrcIlbjXfbc
mwIDAQAB
-----END PUBLIC KEY-----
''';

const _otherRsaPublicKeyPem = '''
-----BEGIN PUBLIC KEY-----
MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBALxv9MxC+3xB2R0f2E8e1eXg6hR8wZnU
f1Sd6U8tve7EJ6F6YxnxQ4mQBTnIe8S1w8mW7V9BUhTEeO0vH4Y1V9ECAwEAAQ==
-----END PUBLIC KEY-----
''';
