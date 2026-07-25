abstract interface class SecretHasher {
  Future<String> hashSecret(String secret);

  Future<bool> verifySecret({
    required String secret,
    required String secretHash,
  });
}
