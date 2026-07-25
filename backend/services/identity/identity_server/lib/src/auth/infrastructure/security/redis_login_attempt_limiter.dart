import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:redis/redis.dart';
import 'package:serverpod/serverpod.dart';

import '../../application/interfaces/login_attempt_limiter.dart';

class RedisLoginAttemptLimiter implements LoginAttemptLimiter {
  const RedisLoginAttemptLimiter({
    this.maxAttempts = 5,
    this.window = const Duration(minutes: 15),
  });

  static const _keyPrefix = 'identity:auth:login_attempts';
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
    required String username,
  }) async {
    final failedAttempts = await _withRedis<int>(
      session,
      (command) async {
        final value = await command.get(_cacheKey(username));
        if (value == null) return 0;
        return int.tryParse('$value') ?? 0;
      },
    );
    return failedAttempts >= maxAttempts;
  }

  @override
  Future<void> registerFailedAttempt(
    Session session, {
    required String username,
  }) async {
    await _withRedis<Object?>(
      session,
      (command) {
        return command.send_object([
          'EVAL',
          _incrementScript,
          '1',
          _cacheKey(username),
          '${window.inMilliseconds}',
        ]);
      },
    );
  }

  @override
  Future<void> registerSuccessfulAttempt(
    Session session, {
    required String username,
  }) async {
    await _withRedis<Object?>(
      session,
      (command) => command.send_object(['DEL', _cacheKey(username)]),
    );
  }

  String _cacheKey(String username) {
    final digest = sha256.convert(utf8.encode(username));
    return '$_keyPrefix:$digest';
  }

  Future<T> _withRedis<T>(
    Session session,
    Future<T> Function(Command command) operation,
  ) async {
    final config = session.serverpod.config.redis;
    if (config == null || !config.enabled) {
      throw StateError('Redis must be enabled for login attempt limiting.');
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
