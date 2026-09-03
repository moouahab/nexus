import 'package:serverpod/serverpod.dart';

abstract interface class EmailVerificationSender {
  Future<void> sendVerificationCode(
    Session session, {
    required String email,
    required String code,
  });
}
