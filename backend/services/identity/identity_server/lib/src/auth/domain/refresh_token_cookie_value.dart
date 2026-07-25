import 'package:serverpod/serverpod.dart';

class RefreshTokenCookieValue {
  const RefreshTokenCookieValue({
    required this.refreshTokenId,
    required this.secret,
  });

  final UuidValue refreshTokenId;
  final String secret;
}
