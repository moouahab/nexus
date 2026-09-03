import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:redis/redis.dart';
import 'package:serverpod/serverpod.dart';

import '../../application/interfaces/otp_rate_limiter.dart';

class RedisOtpRateLimiter implements OtpRateLimiter {
  const RedisOtpRateLimiter({
    this.maxAttempts = 3,
    this.window = const Duration(minutes: 15),
  });

  static const _keyPrefix = 'identity:auth:otp_attempts';
  static const _incrementScript = '''
local existing = redis.call('GET', KEYS[1])
if existing and tonumber(existing) == nil then
  redis.call('DEL', KEYS[1])
end
local current = redis.call('INCR', KEYS[1])
if current == 1 then
  redis.call('PEXPIRE', KEYS[1], ARGV[1])
end
return current
''';

  final int maxAttempts;
  final Duration window;

  @override
  Future<bool> isBlocked(
    Session session, {
    required String action,
    required String subject,
  }) async {
    final attempts = await _withRedis<int>(
      session,
      (command) async {
        final value = await command.get(_cacheKey(action, subject));
        if (value == null) return 0;
        return int.tryParse('$value') ?? 0;
      },
    );
    return attempts >= maxAttempts;
  }

  @override
  Future<void> registerAttempt(
    Session session, {
    required String action,
    required String subject,
  }) async {
    await _withRedis<Object?>(
      session,
      (command) {
        return command.send_object([
          'EVAL',
          _incrementScript,
          '1',
          _cacheKey(action, subject),
          '${window.inMilliseconds}',
        ]);
      },
    );
  }

  String _cacheKey(String action, String subject) {
    final normalized =
        '${action.trim().toLowerCase()}:'
        '${subject.trim().toLowerCase()}';
    final digest = sha256.convert(utf8.encode(normalized));
    return '$_keyPrefix:$digest';
  }

  Future<T> _withRedis<T>(
    Session session,
    Future<T> Function(Command command) operation,
  ) async {
    final config = session.serverpod.config.redis;
    if (config == null || !config.enabled) {
      throw StateError('Redis must be enabled for OTP rate limiting.');
    }

    final connection = RedisConnection();
    final command = switch (config.requireSsl) {
      true => await connection.connectSecure(config.host, config.port),
      false => await connection.connect(config.host, config.port),
    };

    try {
      if (config.password != null) {
        final result = switch (config.user) {
          String user => await command.send_object([
            'AUTH',
            user,
            config.password,
          ]),
          null => await command.send_object(['AUTH', config.password]),
        };

        if (result != 'OK') {
          throw StateError('Redis authentication failed.');
        }
      }

      return await operation(command);
    } finally {
      await command.get_connection().close();
    }
  }
}
