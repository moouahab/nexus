import 'package:serverpod/serverpod.dart';

import '../../application/interfaces/refresh_token_codec.dart';
import '../../domain/refresh_token_cookie_value.dart';

class ColonRefreshTokenCodec implements RefreshTokenCodec {
  static const _separator = ':';

  @override
  String encode({
    required UuidValue refreshTokenId,
    required String secret,
  }) {
    return '${refreshTokenId.toString()}$_separator$secret';
  }

  @override
  RefreshTokenCookieValue decode(String value) {
    final separatorIndex = value.indexOf(_separator);
    if (separatorIndex <= 0 || separatorIndex == value.length - 1) {
      throw const FormatException('Invalid refresh token cookie value.');
    }

    return RefreshTokenCookieValue(
      refreshTokenId: UuidValue.withValidation(
        value.substring(0, separatorIndex),
      ),
      secret: value.substring(separatorIndex + 1),
    );
  }
}
