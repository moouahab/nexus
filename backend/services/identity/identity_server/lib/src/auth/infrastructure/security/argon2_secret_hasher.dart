import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../../application/interfaces/secret_hasher.dart';

class Argon2SecretHasher implements SecretHasher {
  Argon2SecretHasher({
    required String pepper,
    List<String> fallbackPeppers = const [],
    int saltLength = 16,
  }) : _hashUtil = Argon2HashUtil(
         hashPepper: pepper,
         fallbackHashPeppers: fallbackPeppers,
         hashSaltLength: saltLength,
       );

  final Argon2HashUtil _hashUtil;

  @override
  Future<String> hashSecret(String secret) {
    return _hashUtil.createHashFromString(secret: secret);
  }

  @override
  Future<bool> verifySecret({
    required String secret,
    required String secretHash,
  }) {
    return _hashUtil.validateHashFromString(
      secret: secret,
      hashString: secretHash,
    );
  }
}
