abstract interface class PasswordHasher {
  Future<String> hashPassword(String password);

  Future<bool> verifyPassword({
    required String password,
    required String passwordHash,
  });
}
