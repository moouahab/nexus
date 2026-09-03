import 'package:identity_server/src/auth/application/interfaces/auth_refresh_token_repository.dart';
import 'package:identity_server/src/auth/application/interfaces/auth_session_repository.dart';
import 'package:identity_server/src/auth/application/interfaces/email_verification_code_repository.dart';
import 'package:identity_server/src/auth/application/interfaces/email_verification_sender.dart';
import 'package:identity_server/src/auth/application/interfaces/identity_provider_repository.dart';
import 'package:identity_server/src/auth/application/interfaces/identity_repository.dart';
import 'package:identity_server/src/auth/application/interfaces/login_attempt_limiter.dart';
import 'package:identity_server/src/auth/application/interfaces/otp_rate_limiter.dart';
import 'package:identity_server/src/auth/application/interfaces/password_credential_repository.dart';
import 'package:identity_server/src/auth/application/interfaces/password_hasher.dart';
import 'package:identity_server/src/auth/application/interfaces/password_reset_code_repository.dart';
import 'package:identity_server/src/auth/application/interfaces/password_reset_sender.dart';
import 'package:identity_server/src/auth/application/interfaces/refresh_token_secret_service.dart';
import 'package:identity_server/src/auth/application/interfaces/secret_hasher.dart';
import 'package:identity_server/src/auth/application/interfaces/verification_code_generator.dart';
import 'package:identity_server/src/auth/domain/refresh_token_secret.dart';
import 'package:identity_server/src/generated/protocol.dart' as protocol;
import 'package:serverpod/serverpod.dart';

UuidValue newUuid() => const Uuid().v7obj();

class FakePasswordHasher implements PasswordHasher {
  @override
  Future<String> hashPassword(String password) async => 'hash:$password';

  @override
  Future<bool> verifyPassword({
    required String password,
    required String passwordHash,
  }) async {
    return passwordHash == 'hash:$password';
  }
}

class FakeRefreshTokenSecretService implements RefreshTokenSecretService {
  var _nextSecretNumber = 0;

  @override
  Future<RefreshTokenSecret> createSecret() async {
    _nextSecretNumber += 1;
    final raw = 'secret-$_nextSecretNumber';
    return RefreshTokenSecret(raw: raw, hash: 'hash:$raw');
  }

  @override
  Future<bool> verifySecret({
    required String rawSecret,
    required String secretHash,
  }) async {
    return secretHash == 'hash:$rawSecret';
  }
}

class FakeSecretHasher implements SecretHasher {
  @override
  Future<String> hashSecret(String secret) async => 'hash:$secret';

  @override
  Future<bool> verifySecret({
    required String secret,
    required String secretHash,
  }) async {
    return secretHash == 'hash:$secret';
  }
}

class FakeVerificationCodeGenerator implements VerificationCodeGenerator {
  FakeVerificationCodeGenerator({this.nextCode = '12345678'});

  String nextCode;

  @override
  String generate() => nextCode;
}

class FakeEmailVerificationSender implements EmailVerificationSender {
  final sentCodes = <String, String>{};

  @override
  Future<void> sendVerificationCode(
    Session session, {
    required String email,
    required String code,
  }) async {
    sentCodes[email] = code;
  }
}

class FakePasswordResetSender implements PasswordResetSender {
  final sentCodes = <String, String>{};

  @override
  Future<void> sendResetCode(
    Session session, {
    required String email,
    required String code,
  }) async {
    sentCodes[email] = code;
  }
}

class FakeLoginAttemptLimiter implements LoginAttemptLimiter {
  FakeLoginAttemptLimiter({this.maxAttempts = 5});

  final int maxAttempts;
  final Map<String, int> failedAttempts = {};

  @override
  Future<bool> isBlocked(
    Session session, {
    required String username,
  }) async {
    return (failedAttempts[username] ?? 0) >= maxAttempts;
  }

  @override
  Future<void> registerFailedAttempt(
    Session session, {
    required String username,
  }) async {
    failedAttempts[username] = (failedAttempts[username] ?? 0) + 1;
  }

  @override
  Future<void> registerSuccessfulAttempt(
    Session session, {
    required String username,
  }) async {
    failedAttempts.remove(username);
  }
}

class FakeOtpRateLimiter implements OtpRateLimiter {
  FakeOtpRateLimiter({this.maxAttempts = 3});

  final int maxAttempts;
  final Map<String, int> attempts = {};

  @override
  Future<bool> isBlocked(
    Session session, {
    required String action,
    required String subject,
  }) async {
    return (attempts[_key(action, subject)] ?? 0) >= maxAttempts;
  }

  @override
  Future<void> registerAttempt(
    Session session, {
    required String action,
    required String subject,
  }) async {
    final key = _key(action, subject);
    attempts[key] = (attempts[key] ?? 0) + 1;
  }

  String _key(String action, String subject) {
    return '${action.trim().toLowerCase()}:${subject.trim().toLowerCase()}';
  }
}

class FakeEmailVerificationCodeRepository
    implements EmailVerificationCodeRepository {
  final Map<UuidValue, protocol.EmailVerificationCode> byId = {};

  @override
  Future<protocol.EmailVerificationCode> create(
    Session session, {
    required UuidValue identityId,
    required String email,
    required String codeHash,
    required DateTime expiresAt,
  }) async {
    final code = protocol.EmailVerificationCode(
      id: newUuid(),
      identityId: identityId,
      email: email,
      codeHash: codeHash,
      expiresAt: expiresAt,
    );
    byId[code.id!] = code;
    return code;
  }

  @override
  Future<protocol.EmailVerificationCode?> findActiveByIdentityId(
    Session session,
    UuidValue identityId,
  ) async {
    final now = DateTime.now().toUtc();
    final active =
        byId.values
            .where(
              (code) =>
                  code.identityId == identityId &&
                  code.consumedAt == null &&
                  code.expiresAt.isAfter(now),
            )
            .toList()
          ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return active.firstOrNull;
  }

  @override
  Future<void> markConsumed(Session session, UuidValue id) async {
    final code = byId[id];
    if (code == null) return;
    byId[id] = code.copyWith(consumedAt: DateTime.now().toUtc());
  }

  @override
  Future<void> registerFailedAttempt(Session session, UuidValue id) async {
    final code = byId[id];
    if (code == null) return;
    byId[id] = code.copyWith(failedAttempts: code.failedAttempts + 1);
  }

  @override
  Future<void> revokeActiveForIdentity(
    Session session,
    UuidValue identityId,
  ) async {
    final now = DateTime.now().toUtc();
    for (final code in byId.values.where(
      (code) => code.identityId == identityId && code.consumedAt == null,
    )) {
      byId[code.id!] = code.copyWith(consumedAt: now);
    }
  }
}

class FakePasswordResetCodeRepository implements PasswordResetCodeRepository {
  final Map<UuidValue, protocol.PasswordResetCode> byId = {};

  @override
  Future<protocol.PasswordResetCode> create(
    Session session, {
    required UuidValue identityId,
    required String email,
    required String codeHash,
    required DateTime expiresAt,
  }) async {
    final code = protocol.PasswordResetCode(
      id: newUuid(),
      identityId: identityId,
      email: email,
      codeHash: codeHash,
      expiresAt: expiresAt,
    );
    byId[code.id!] = code;
    return code;
  }

  @override
  Future<protocol.PasswordResetCode?> findActiveByIdentityId(
    Session session,
    UuidValue identityId,
  ) async {
    final now = DateTime.now().toUtc();
    final active =
        byId.values
            .where(
              (code) =>
                  code.identityId == identityId &&
                  code.consumedAt == null &&
                  code.expiresAt.isAfter(now),
            )
            .toList()
          ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return active.firstOrNull;
  }

  @override
  Future<void> markConsumed(Session session, UuidValue id) async {
    final code = byId[id];
    if (code == null) return;
    byId[id] = code.copyWith(consumedAt: DateTime.now().toUtc());
  }

  @override
  Future<void> registerFailedAttempt(Session session, UuidValue id) async {
    final code = byId[id];
    if (code == null) return;
    byId[id] = code.copyWith(failedAttempts: code.failedAttempts + 1);
  }

  @override
  Future<void> revokeActiveForIdentity(
    Session session,
    UuidValue identityId,
  ) async {
    final now = DateTime.now().toUtc();
    for (final code in byId.values.where(
      (code) => code.identityId == identityId && code.consumedAt == null,
    )) {
      byId[code.id!] = code.copyWith(consumedAt: now);
    }
  }
}

class FakeIdentityRepository implements IdentityRepository {
  final Map<UuidValue, protocol.Identity> byId = {};

  @override
  Future<protocol.Identity> create(
    Session session, {
    String? email,
    String? username,
    bool emailVerified = false,
    protocol.IdentityStatus status = protocol.IdentityStatus.active,
  }) async {
    final identity = protocol.Identity(
      id: newUuid(),
      email: email,
      username: username,
      emailVerified: emailVerified,
      status: status,
    );
    byId[identity.id!] = identity;
    return identity;
  }

  @override
  Future<protocol.Identity?> findById(Session session, UuidValue id) async {
    return byId[id];
  }

  @override
  Future<protocol.Identity?> findByEmail(Session session, String email) async {
    return byId.values.where((identity) => identity.email == email).firstOrNull;
  }

  @override
  Future<protocol.Identity?> findByUsername(
    Session session,
    String username,
  ) async {
    return byId.values
        .where((identity) => identity.username == username)
        .firstOrNull;
  }

  @override
  Future<protocol.Identity?> markEmailVerified(
    Session session,
    UuidValue id,
  ) async {
    final identity = byId[id];
    if (identity == null) return null;
    final updated = identity.copyWith(emailVerified: true);
    byId[id] = updated;
    return updated;
  }

  @override
  Future<protocol.Identity?> updateEmail(
    Session session, {
    required UuidValue id,
    required String email,
    required bool emailVerified,
  }) async {
    final identity = byId[id];
    if (identity == null) return null;
    final updated = identity.copyWith(
      email: email,
      emailVerified: emailVerified,
    );
    byId[id] = updated;
    return updated;
  }

  @override
  Future<protocol.Identity?> updateStatus(
    Session session,
    UuidValue id,
    protocol.IdentityStatus status,
  ) async {
    final identity = byId[id];
    if (identity == null) return null;
    final updated = identity.copyWith(status: status);
    byId[id] = updated;
    return updated;
  }
}

class FakeIdentityProviderRepository implements IdentityProviderRepository {
  final Map<UuidValue, protocol.IdentityProvider> byId = {};

  @override
  Future<protocol.IdentityProvider> create(
    Session session, {
    required UuidValue identityId,
    required protocol.AuthProvider provider,
    required String providerUserId,
    String? email,
    bool emailVerified = false,
  }) async {
    final identityProvider = protocol.IdentityProvider(
      id: newUuid(),
      identityId: identityId,
      provider: provider,
      providerUserId: providerUserId,
      email: email,
      emailVerified: emailVerified,
    );
    byId[identityProvider.id!] = identityProvider;
    return identityProvider;
  }

  @override
  Future<List<protocol.IdentityProvider>> findByIdentityId(
    Session session,
    UuidValue identityId,
  ) async {
    return byId.values
        .where((provider) => provider.identityId == identityId)
        .toList();
  }

  @override
  Future<protocol.IdentityProvider?> findByProviderUserId(
    Session session, {
    required protocol.AuthProvider provider,
    required String providerUserId,
  }) async {
    return byId.values
        .where(
          (item) =>
              item.provider == provider &&
              item.providerUserId == providerUserId,
        )
        .firstOrNull;
  }

  @override
  Future<protocol.IdentityProvider?> markUsed(
    Session session,
    UuidValue id,
  ) async {
    final provider = byId[id];
    if (provider == null) return null;
    final updated = provider.copyWith(lastUsedAt: DateTime.now().toUtc());
    byId[id] = updated;
    return updated;
  }

  @override
  Future<List<protocol.IdentityProvider>> updateEmailForIdentity(
    Session session, {
    required UuidValue identityId,
    required String email,
    required bool emailVerified,
  }) async {
    final updated = <protocol.IdentityProvider>[];
    for (final provider in byId.values.where(
      (provider) => provider.identityId == identityId,
    )) {
      final next = provider.copyWith(
        email: email,
        emailVerified: emailVerified,
      );
      byId[next.id!] = next;
      updated.add(next);
    }
    return updated;
  }
}

class FakePasswordCredentialRepository implements PasswordCredentialRepository {
  final Map<String, protocol.PasswordCredential> byUsername = {};

  @override
  Future<protocol.PasswordCredential> create(
    Session session, {
    required UuidValue identityId,
    required String username,
    required String passwordHash,
  }) async {
    final credential = protocol.PasswordCredential(
      id: newUuid(),
      identityId: identityId,
      username: username,
      passwordHash: passwordHash,
    );
    byUsername[username] = credential;
    return credential;
  }

  @override
  Future<protocol.PasswordCredential?> findByUsername(
    Session session,
    String username,
  ) async {
    return byUsername[username];
  }

  @override
  Future<protocol.PasswordCredential?> findByIdentityId(
    Session session,
    UuidValue identityId,
  ) async {
    return byUsername.values
        .where((credential) => credential.identityId == identityId)
        .firstOrNull;
  }

  @override
  Future<protocol.PasswordCredential?> updatePasswordHash(
    Session session, {
    required UuidValue id,
    required String passwordHash,
  }) async {
    final credential = byUsername.values
        .where((credential) => credential.id == id)
        .firstOrNull;
    if (credential == null) return null;
    final updated = credential.copyWith(passwordHash: passwordHash);
    byUsername[updated.username] = updated;
    return updated;
  }
}

class FakeAuthSessionRepository implements AuthSessionRepository {
  final Map<UuidValue, protocol.AuthSession> byId = {};

  @override
  Future<protocol.AuthSession> create(
    Session session, {
    required UuidValue identityId,
    required DateTime expiresAt,
    required protocol.AuthProvider authMethod,
  }) async {
    final authSession = protocol.AuthSession(
      id: newUuid(),
      identityId: identityId,
      expiresAt: expiresAt,
      authMethod: authMethod,
    );
    byId[authSession.id!] = authSession;
    return authSession;
  }

  @override
  Future<protocol.AuthSession?> findActiveById(
    Session session,
    UuidValue id,
  ) async {
    final authSession = byId[id];
    if (authSession == null) return null;
    if (authSession.revokedAt != null) return null;
    if (!authSession.expiresAt.isAfter(DateTime.now().toUtc())) return null;
    return authSession;
  }

  @override
  Future<protocol.AuthSession?> findById(Session session, UuidValue id) async {
    return byId[id];
  }

  @override
  Future<List<protocol.AuthSession>> revokeAllForIdentity(
    Session session,
    UuidValue identityId,
  ) async {
    final revoked = <protocol.AuthSession>[];
    for (final authSession in byId.values) {
      if (authSession.identityId != identityId) continue;
      final updated = authSession.copyWith(revokedAt: DateTime.now().toUtc());
      byId[authSession.id!] = updated;
      revoked.add(updated);
    }
    return revoked;
  }

  @override
  Future<protocol.AuthSession?> revoke(Session session, UuidValue id) async {
    final authSession = byId[id];
    if (authSession == null) return null;
    final updated = authSession.copyWith(revokedAt: DateTime.now().toUtc());
    byId[id] = updated;
    return updated;
  }

  @override
  Future<protocol.AuthSession?> touch(Session session, UuidValue id) async {
    final authSession = byId[id];
    if (authSession == null) return null;
    final updated = authSession.copyWith(lastUsedAt: DateTime.now().toUtc());
    byId[id] = updated;
    return updated;
  }
}

class FakeAuthRefreshTokenRepository implements AuthRefreshTokenRepository {
  final Map<UuidValue, protocol.AuthRefreshToken> byId = {};

  @override
  Future<protocol.AuthRefreshToken> create(
    Session session, {
    required UuidValue authSessionId,
    required String tokenHash,
    required DateTime expiresAt,
  }) async {
    final refreshToken = protocol.AuthRefreshToken(
      id: newUuid(),
      authSessionId: authSessionId,
      tokenHash: tokenHash,
      expiresAt: expiresAt,
    );
    byId[refreshToken.id!] = refreshToken;
    return refreshToken;
  }

  @override
  Future<protocol.AuthRefreshToken?> findActiveById(
    Session session,
    UuidValue id,
  ) async {
    final refreshToken = byId[id];
    if (refreshToken == null) return null;
    if (refreshToken.revokedAt != null || refreshToken.rotatedAt != null) {
      return null;
    }
    if (!refreshToken.expiresAt.isAfter(DateTime.now().toUtc())) return null;
    return refreshToken;
  }

  @override
  Future<protocol.AuthRefreshToken?> findById(
    Session session,
    UuidValue id,
  ) async {
    return byId[id];
  }

  @override
  Future<protocol.AuthRefreshToken?> revoke(
    Session session,
    UuidValue id,
  ) async {
    final refreshToken = byId[id];
    if (refreshToken == null) return null;
    final updated = refreshToken.copyWith(revokedAt: DateTime.now().toUtc());
    byId[id] = updated;
    return updated;
  }

  @override
  Future<protocol.AuthRefreshToken?> rotate(
    Session session, {
    required UuidValue oldTokenId,
    required UuidValue newTokenId,
  }) async {
    final refreshToken = byId[oldTokenId];
    if (refreshToken == null) return null;
    final updated = refreshToken.copyWith(
      rotatedAt: DateTime.now().toUtc(),
      replacedByTokenId: newTokenId,
    );
    byId[oldTokenId] = updated;
    return updated;
  }
}
