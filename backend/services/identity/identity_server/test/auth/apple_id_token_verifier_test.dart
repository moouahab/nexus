import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:identity_server/src/auth/application/exceptions/auth_use_case_exception.dart';
import 'package:identity_server/src/auth/infrastructure/oauth/apple_id_token_verifier.dart';
import 'package:identity_server/src/auth/infrastructure/oauth/oauth_http_client.dart';
import 'package:test/test.dart';

void main() {
  group('AppleIdTokenVerifier', () {
    test('verifies an Apple id token signature and claims from JWKS', () async {
      final verifier = AppleIdTokenVerifier(httpClient: _JwksHttpClient());
      final now = DateTime.now().toUtc();
      final token = _appleToken(
        audience: 'com.nexus.service',
        issuedAt: now,
        expiresAt: now.add(const Duration(minutes: 5)),
      );

      final claims = await verifier.verify(
        idToken: token,
        audience: 'com.nexus.service',
      );

      expect(claims['sub'], 'apple-user-1');
      expect(claims['email'], 'noxe@example.com');
    });

    test('rejects tokens with the wrong audience', () async {
      final verifier = AppleIdTokenVerifier(httpClient: _JwksHttpClient());
      final now = DateTime.now().toUtc();
      final token = _appleToken(
        audience: 'other.service',
        issuedAt: now,
        expiresAt: now.add(const Duration(minutes: 5)),
      );

      await expectLater(
        verifier.verify(idToken: token, audience: 'com.nexus.service'),
        throwsA(isA<AuthUseCaseException>()),
      );
    });
  });
}

class _JwksHttpClient extends OAuthHttpClient {
  @override
  Future<OAuthHttpResponse> getJson(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    return OAuthHttpResponse(
      statusCode: 200,
      body: {
        'keys': [_rsaPublicKey.toJWK()],
      },
    );
  }
}

String _appleToken({
  required String audience,
  required DateTime issuedAt,
  required DateTime expiresAt,
}) {
  final jwt = JWT({
    'iss': 'https://appleid.apple.com',
    'aud': audience,
    'sub': 'apple-user-1',
    'email': 'noxe@example.com',
    'email_verified': 'true',
    'iat': issuedAt.millisecondsSinceEpoch ~/ 1000,
  });

  return jwt.sign(
    _rsaPrivateKey,
    algorithm: JWTAlgorithm.RS256,
    expiresIn: expiresAt.difference(issuedAt),
  );
}

// Public test fixture key used only to sign local JWTs in unit tests.
final _rsaPrivateKey = RSAPrivateKey(
  _pem('PRIVATE KEY', '''
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
'''),
);

final _rsaPublicKey = RSAPublicKey('''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu1SU1LfVLPHCozMxH2Mo
4lgOEePzNm0tRgeLezV6ffAt0gunVTLw7onLRnrq0/IzW7yWR7QkrmBL7jTKEn5u
+qKhbwKfBstIs+bMY2Zkp18gnTxKLxoS2tFczGkPLPgizskuemMghRniWaoLcyeh
kd3qqGElvW/VDL5AaWTg0nLVkjRo9z+40RQzuVaE8AkAFmxZzow3x+VJYKdjykkJ
0iT9wCS0DRTXu269V264Vf/3jvredZiKRkgwlL9xNAwxXFg0x/XFw005UWVRIkdg
cKWTjpBP2dPwVZ4WWC+9aGVd+Gyn1o0CLelf4rEjGoXbAAEgAqeGUxrcIlbjXfbc
mwIDAQAB
-----END PUBLIC KEY-----''');

String _pem(String label, String body) {
  return '-----BEGIN $label-----\n${body.trim()}\n-----END $label-----';
}
