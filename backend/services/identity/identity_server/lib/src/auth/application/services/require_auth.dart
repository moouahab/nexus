import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../constants/auth_cookie_names.dart';
import '../../domain/authenticated_request.dart';
import '../../domain/auth_claims.dart';
import '../exceptions/authentication_required_exception.dart';
import '../interfaces/access_token_service.dart';
import '../interfaces/auth_cookie_service.dart';
import '../interfaces/auth_session_repository.dart';
import '../interfaces/identity_repository.dart';

class RequireAuth {
  const RequireAuth({
    required AccessTokenService accessTokenService,
    required AuthCookieService authCookieService,
    required AuthSessionRepository authSessionRepository,
    required IdentityRepository identityRepository,
  }) : _accessTokenService = accessTokenService,
       _authCookieService = authCookieService,
       _authSessionRepository = authSessionRepository,
       _identityRepository = identityRepository;

  final AccessTokenService _accessTokenService;
  final AuthCookieService _authCookieService;
  final AuthSessionRepository _authSessionRepository;
  final IdentityRepository _identityRepository;

  Future<AuthenticatedRequest> fromHeaders(
    Session session, {
    required Map<String, List<String>> headers,
  }) async {
    final accessToken = _readAccessToken(headers);
    final claims = _verifyAccessToken(accessToken);
    final authSession = await _findActiveSession(session, claims.authSessionId);
    final identity = await _findActiveIdentity(session, claims.identityId);

    return AuthenticatedRequest(
      identityId: claims.identityId,
      authSessionId: claims.authSessionId,
      claims: claims,
      identity: identity,
      authSession: authSession,
    );
  }

  String _readAccessToken(Map<String, List<String>> headers) {
    final accessToken = _authCookieService.readCookie(
      headers: headers,
      name: AuthCookieNames.accessToken,
    );
    if (accessToken != null && accessToken.isNotEmpty) return accessToken;

    throw const AuthenticationRequiredException(
      AuthenticationRequiredExceptionCode.missingAccessToken,
    );
  }

  AuthClaims _verifyAccessToken(String accessToken) {
    try {
      return _accessTokenService.verifyAccessToken(accessToken);
    } on Exception {
      throw const AuthenticationRequiredException(
        AuthenticationRequiredExceptionCode.invalidAccessToken,
      );
    }
  }

  Future<protocol.AuthSession> _findActiveSession(
    Session session,
    UuidValue authSessionId,
  ) async {
    final authSession = await _authSessionRepository.findActiveById(
      session,
      authSessionId,
    );
    if (authSession != null) return authSession;

    throw const AuthenticationRequiredException(
      AuthenticationRequiredExceptionCode.sessionNotFound,
    );
  }

  Future<protocol.Identity> _findActiveIdentity(
    Session session,
    UuidValue identityId,
  ) async {
    final identity = await _identityRepository.findById(session, identityId);
    if (identity == null) {
      throw const AuthenticationRequiredException(
        AuthenticationRequiredExceptionCode.identityNotFound,
      );
    }

    if (identity.status != protocol.IdentityStatus.active) {
      throw const AuthenticationRequiredException(
        AuthenticationRequiredExceptionCode.identityNotActive,
      );
    }

    return identity;
  }
}
