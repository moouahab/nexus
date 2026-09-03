import 'package:serverpod/serverpod.dart';

abstract interface class OtpRateLimiter {
  Future<bool> isBlocked(
    Session session, {
    required String action,
    required String subject,
  });

  Future<void> registerAttempt(
    Session session, {
    required String action,
    required String subject,
  });
}
