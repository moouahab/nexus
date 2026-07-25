import '../../domain/auth_claims.dart';

abstract interface class AccessTokenService {
  String createAccessToken(AuthClaims claims);

  AuthClaims verifyAccessToken(String token);
}
