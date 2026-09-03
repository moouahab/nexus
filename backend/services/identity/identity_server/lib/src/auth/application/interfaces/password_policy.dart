abstract interface class PasswordPolicy {
  void validate({
    required String password,
    required String username,
    String? email,
  });
}
