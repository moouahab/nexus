import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../../application/interfaces/password_hasher.dart';

class Argon2PasswordHasher implements PasswordHasher {
  Argon2PasswordHasher({
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
  Future<String> hashPassword(String password) {
    return _hashUtil.createHashFromString(secret: password);
  }

  @override
  Future<bool> verifyPassword({
    required String password,
    required String passwordHash,
  }) {
    return _hashUtil.validateHashFromString(
      secret: password,
      hashString: passwordHash,
    );
  }
}
