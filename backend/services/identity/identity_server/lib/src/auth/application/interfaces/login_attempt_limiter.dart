import 'package:serverpod/serverpod.dart';

abstract interface class LoginAttemptLimiter {
  Future<bool> isBlocked(
    Session session, {
    required String username,
  });

  Future<void> registerFailedAttempt(
    Session session, {
    required String username,
  });

  Future<void> registerSuccessfulAttempt(
    Session session, {
    required String username,
  });
}
