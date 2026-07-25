import 'dart:convert';
import 'dart:math';

import '../../application/interfaces/refresh_token_secret_service.dart';
import '../../application/interfaces/secret_hasher.dart';
import '../../domain/refresh_token_secret.dart';

class SecureRefreshTokenSecretService implements RefreshTokenSecretService {
  SecureRefreshTokenSecretService({
    required SecretHasher secretHasher,
    Random? random,
    int byteLength = 48,
  }) : _secretHasher = secretHasher,
       _random = random ?? Random.secure(),
       _byteLength = byteLength;

  final SecretHasher _secretHasher;
  final Random _random;
  final int _byteLength;

  @override
  Future<RefreshTokenSecret> createSecret() async {
    final raw = _generateUrlSafeSecret();
    final hash = await _secretHasher.hashSecret(raw);
    return RefreshTokenSecret(raw: raw, hash: hash);
  }

  @override
  Future<bool> verifySecret({
    required String rawSecret,
    required String secretHash,
  }) {
    return _secretHasher.verifySecret(
      secret: rawSecret,
      secretHash: secretHash,
    );
  }

  String _generateUrlSafeSecret() {
    final bytes = List<int>.generate(_byteLength, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
