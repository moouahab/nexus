import 'package:identity_server/src/auth/application/interfaces/auth_refresh_token_repository.dart';
import 'package:identity_server/src/auth/application/interfaces/auth_session_repository.dart';
import 'package:identity_server/src/auth/application/interfaces/identity_provider_repository.dart';
import 'package:identity_server/src/auth/application/interfaces/identity_repository.dart';
import 'package:identity_server/src/auth/application/interfaces/login_attempt_limiter.dart';
import 'package:identity_server/src/auth/application/interfaces/password_credential_repository.dart';
import 'package:identity_server/src/auth/application/interfaces/password_hasher.dart';
import 'package:identity_server/src/auth/application/interfaces/refresh_token_secret_service.dart';
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
