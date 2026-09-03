import 'package:identity_server/src/auth/infrastructure/security/redis_otp_rate_limiter.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'RedisOtpRateLimiter',
    (sessionBuilder, endpoints) {
      late Session session;

      setUp(() {
        session = sessionBuilder.build();
      });

      tearDown(() async {
        await session.close();
      });

      test('blocks after max attempts', () async {
        final limiter = RedisOtpRateLimiter(
          maxAttempts: 2,
          window: const Duration(minutes: 15),
        );
        final subject = _uniqueEmail('otp-block');

        expect(
          await limiter.isBlocked(
            session,
            action: 'password_reset_start',
            subject: subject,
          ),
          isFalse,
        );

        await limiter.registerAttempt(
          session,
          action: 'password_reset_start',
          subject: subject,
        );
        await limiter.registerAttempt(
          session,
          action: 'password_reset_start',
          subject: subject,
        );

        expect(
          await limiter.isBlocked(
            session,
            action: 'password_reset_start',
            subject: subject,
          ),
          isTrue,
        );
      });

      test('uses separate buckets per action and subject', () async {
        final limiter = RedisOtpRateLimiter(
          maxAttempts: 1,
          window: const Duration(minutes: 15),
        );
        final subject = _uniqueEmail('otp-bucket');

        await limiter.registerAttempt(
          session,
          action: 'email_verification_resend',
          subject: subject,
        );

        expect(
          await limiter.isBlocked(
            session,
            action: 'email_verification_resend',
            subject: subject,
          ),
          isTrue,
        );
        expect(
          await limiter.isBlocked(
            session,
            action: 'password_reset_start',
            subject: subject,
          ),
          isFalse,
        );
        expect(
          await limiter.isBlocked(
            session,
            action: 'email_verification_resend',
            subject: 'other@example.com',
          ),
          isFalse,
        );
      });
    },
  );
}

String _uniqueEmail(String prefix) {
  return '$prefix-${DateTime.now().microsecondsSinceEpoch}@example.com';
}
