import 'package:identity_server/src/auth/infrastructure/security/colon_refresh_token_codec.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('ColonRefreshTokenCodec', () {
    test('encodes and decodes refresh token id with raw secret', () {
      final codec = ColonRefreshTokenCodec();
      final refreshTokenId = const Uuid().v7obj();

      final encoded = codec.encode(
        refreshTokenId: refreshTokenId,
        secret: 'secret-value',
      );
      final decoded = codec.decode(encoded);

      expect(decoded.refreshTokenId, refreshTokenId);
      expect(decoded.secret, 'secret-value');
    });

    test('rejects malformed cookie values', () {
      final codec = ColonRefreshTokenCodec();

      expect(() => codec.decode('missing-separator'), throwsFormatException);
      expect(() => codec.decode(':missing-id'), throwsFormatException);
      expect(
        () => codec.decode('${const Uuid().v7()}:'),
        throwsFormatException,
      );
      expect(
        () => codec.decode('not-a-uuid:secret'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
