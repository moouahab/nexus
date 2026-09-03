import 'package:serverpod/serverpod.dart';

abstract interface class PasswordResetSender {
  Future<void> sendResetCode(
    Session session, {
    required String email,
    required String code,
  });
}
