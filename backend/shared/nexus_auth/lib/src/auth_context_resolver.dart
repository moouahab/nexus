import 'package:serverpod/serverpod.dart';

import 'auth_context.dart';
import 'auth_token_defaults.dart';
import 'bearer_access_token_reader.dart';
import 'nexus_auth_exception.dart';
import 'rs256_access_token_verifier.dart';
import 'service_auth_context.dart';

class AuthContextResolver {
  const AuthContextResolver({
    this.passwordKey = 'identityAccessTokenPublicKeyPem',
    this.issuer = AuthTokenDefaults.issuer,
    this.audience = AuthTokenDefaults.audience,
    this.accessTokenReader = const BearerAccessTokenReader(),
  });

  final String passwordKey;
  final String issuer;
  final String audience;
  final BearerAccessTokenReader accessTokenReader;

  AuthContext requireContext(Session session) {
    final accessToken = _requireBearerToken(session);
    return _verifier(session).verify(accessToken);
  }

  ServiceAuthContext requireServiceContext(
    Session session, {
    Iterable<String> requiredScopes = const [],
  }) {
    final accessToken = _requireBearerToken(session);
    return _verifier(
      session,
    ).verifyServiceToken(accessToken, requiredScopes: requiredScopes);
  }

  Rs256AccessTokenVerifier _verifier(Session session) {
    final secret = session.passwords[passwordKey];
    if (secret == null || secret.isEmpty || secret == '<no value>') {
      throw NexusAuthException.missingAuthSecret(passwordKey);
    }
    return Rs256AccessTokenVerifier(
      publicKeyPem: secret,
      issuer: issuer,
      audience: audience,
    );
  }

  String _requireBearerToken(Session session) {
    final request = session.request;
    if (request == null) {
      throw const NexusAuthException.missingRequest();
    }

    final accessToken = accessTokenReader.read(_requestHeaders(request));
    if (accessToken == null || accessToken.isEmpty) {
      throw const NexusAuthException.missingAccessToken();
    }
    return accessToken;
  }

  Map<String, List<String>> _requestHeaders(Request request) {
    return {
      for (final entry in request.headers.entries)
        entry.key.toLowerCase(): entry.value.toList(growable: false),
    };
  }
}
