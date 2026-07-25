import '../../domain/refresh_token_secret.dart';

abstract interface class RefreshTokenSecretService {
  Future<RefreshTokenSecret> createSecret();

  Future<bool> verifySecret({
    required String rawSecret,
    required String secretHash,
  });
}
