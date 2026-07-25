import 'package:identity_server/src/auth/infrastructure/security/redis_login_attempt_limiter.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'RedisLoginAttemptLimiter',
    (sessionBuilder, endpoints) {
      late Session session;

      setUp(() {
        session = sessionBuilder.build();
      });

      tearDown(() async {
        await session.close();
      });

      test(
        'blocks after max attempts and clears after successful login',
        () async {
          final limiter = RedisLoginAttemptLimiter(
            maxAttempts: 2,
            window: const Duration(minutes: 15),
          );

          expect(
            await limiter.isBlocked(session, username: 'noxe@example.com'),
            isFalse,
          );

          await limiter.registerFailedAttempt(
            session,
            username: 'noxe@example.com',
          );
          expect(
            await limiter.isBlocked(session, username: 'noxe@example.com'),
            isFalse,
          );

          await limiter.registerFailedAttempt(
            session,
            username: 'noxe@example.com',
          );
          expect(
            await limiter.isBlocked(session, username: 'noxe@example.com'),
            isTrue,
          );

          await limiter.registerSuccessfulAttempt(
            session,
            username: 'noxe@example.com',
          );
          expect(
            await limiter.isBlocked(session, username: 'noxe@example.com'),
            isFalse,
          );
        },
      );

      test('uses separate buckets per normalized login', () async {
        final limiter = RedisLoginAttemptLimiter(
          maxAttempts: 1,
          window: const Duration(minutes: 15),
        );

        await limiter.registerFailedAttempt(session, username: 'noxe');

        expect(await limiter.isBlocked(session, username: 'noxe'), isTrue);
        expect(await limiter.isBlocked(session, username: 'other'), isFalse);
      });
    },
  );
}
