import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../domain/auth_result.dart';
import '../../domain/auth_token_transport.dart';
import '../exceptions/auth_use_case_exception.dart';
import '../interfaces/identity_provider_repository.dart';
import '../interfaces/identity_repository.dart';
import '../interfaces/oauth_provider_verifier.dart';
import '../services/auth_audit.dart';
import '../services/auth_token_issuer.dart';
import '../validation/termination_rule.dart';

class LoginWithOAuthUseCase {
  const LoginWithOAuthUseCase({
    required IdentityRepository identityRepository,
    required IdentityProviderRepository identityProviderRepository,
    required Map<protocol.AuthProvider, OAuthProviderVerifier> verifiers,
    required AuthTokenIssuer authTokenIssuer,
  }) : _identityRepository = identityRepository,
       _identityProviderRepository = identityProviderRepository,
       _verifiers = verifiers,
       _authTokenIssuer = authTokenIssuer;

  final IdentityRepository _identityRepository;
  final IdentityProviderRepository _identityProviderRepository;
  final Map<protocol.AuthProvider, OAuthProviderVerifier> _verifiers;
  final AuthTokenIssuer _authTokenIssuer;

  Future<AuthResult> execute(
    Session session, {
    required protocol.AuthProvider provider,
    required String code,
    String? redirectUri,
    String? codeVerifier,
    AuthTokenTransport tokenTransport = AuthTokenTransport.cookie,
  }) async {
    final verifier = _verifiers[provider];
    if (verifier == null) {
      AuthAudit.log(
        session,
        event: 'oauth_login',
        outcome: 'blocked',
        reasonCode: 'provider_not_configured',
        provider: provider,
        tokenTransport: tokenTransport.name,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.oauthProviderNotConfigured,
      );
    }

    late final OAuthProviderProfile profile;
    try {
      profile = await verifier.verify(
        session,
        code: code,
        redirectUri: redirectUri,
        codeVerifier: codeVerifier,
      );
    } on AuthUseCaseException catch (exception) {
      AuthAudit.log(
        session,
        event: 'oauth_login',
        outcome: 'failure',
        reasonCode: exception.code.name,
        provider: provider,
        tokenTransport: tokenTransport.name,
      );
      rethrow;
    }

    final normalizedProviderUserId = profile.providerUserId.trim();
    if (normalizedProviderUserId.isEmpty || profile.provider != provider) {
      AuthAudit.log(
        session,
        event: 'oauth_login',
        outcome: 'failure',
        reasonCode: 'invalid_profile',
        provider: provider,
        tokenTransport: tokenTransport.name,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    final normalizedEmail = _normalizeOptional(profile.email);
    var linkedProvider = await _identityProviderRepository.findByProviderUserId(
      session,
      provider: provider,
      providerUserId: normalizedProviderUserId,
    );

    protocol.Identity identity;
    if (linkedProvider != null) {
      identity = await _loadActiveIdentity(session, linkedProvider.identityId);
      await _identityProviderRepository.markUsed(session, linkedProvider.id!);
    } else {
      identity = await _identityForNewProvider(
        session,
        profile: profile,
        normalizedProviderUserId: normalizedProviderUserId,
        normalizedEmail: normalizedEmail,
      );
      linkedProvider = await _identityProviderRepository.create(
        session,
        identityId: identity.id!,
        provider: provider,
        providerUserId: normalizedProviderUserId,
        email: normalizedEmail,
        emailVerified: profile.emailVerified,
      );
      await _identityProviderRepository.markUsed(session, linkedProvider.id!);
    }

    final result = await _authTokenIssuer.issue(
      session,
      identity: identity,
      authMethod: provider,
      tokenTransport: tokenTransport,
    );
    AuthAudit.log(
      session,
      event: 'oauth_login',
      outcome: 'success',
      identityId: identity.id,
      authSessionId: result.authSessionId,
      provider: provider,
      tokenTransport: tokenTransport.name,
      subject: normalizedEmail ?? normalizedProviderUserId,
    );
    return result;
  }

  Future<protocol.Identity> _identityForNewProvider(
    Session session, {
    required OAuthProviderProfile profile,
    required String normalizedProviderUserId,
    required String? normalizedEmail,
  }) async {
    if (normalizedEmail != null) {
      final existingIdentity = await _identityRepository.findByEmail(
        session,
        normalizedEmail,
      );
      if (existingIdentity != null) {
        if (!profile.emailVerified) {
          AuthAudit.log(
            session,
            event: 'oauth_login',
            outcome: 'blocked',
            reasonCode: 'email_already_exists_unverified',
            provider: profile.provider,
            subject: normalizedEmail,
          );
          throw const AuthUseCaseException(
            AuthUseCaseExceptionCode.emailAlreadyExists,
          );
        }
        return _requireActiveIdentity(existingIdentity);
      }
    }

    final identity = await _identityRepository.create(
      session,
      email: normalizedEmail,
      emailVerified: profile.emailVerified,
      status: protocol.IdentityStatus.active,
    );
    if (identity.id == null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.missingGeneratedId,
      );
    }

    return identity;
  }

  Future<protocol.Identity> _loadActiveIdentity(
    Session session,
    UuidValue identityId,
  ) async {
    final identity = await _identityRepository.findById(session, identityId);
    TerminationRule.validateAll([
      TerminationRule(
        shouldTerminate: () => identity == null,
        exception: const AuthUseCaseException(
          AuthUseCaseExceptionCode.identityNotFound,
        ),
      ),
    ]);

    return _requireActiveIdentity(identity!);
  }

  protocol.Identity _requireActiveIdentity(protocol.Identity identity) {
    if (identity.status != protocol.IdentityStatus.active) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.identityNotActive,
      );
    }

    return identity;
  }

  String? _normalizeOptional(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }
}
