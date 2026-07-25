import 'package:serverpod/serverpod.dart';

import '../../domain/refresh_token_cookie_value.dart';

abstract interface class RefreshTokenCodec {
  String encode({
    required UuidValue refreshTokenId,
    required String secret,
  });

  RefreshTokenCookieValue decode(String value);
}
