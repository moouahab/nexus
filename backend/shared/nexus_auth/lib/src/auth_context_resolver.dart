import 'package:serverpod/serverpod.dart';

import 'auth_context.dart';
import 'bearer_access_token_reader.dart';
import 'nexus_auth_exception.dart';
import 'rs256_access_token_verifier.dart';

class AuthContextResolver {
  const AuthContextResolver({
    this.passwordKey = 'identityAccessTokenPublicKeyPem',
    this.accessTokenReader = const BearerAccessTokenReader(),
  });

  final String passwordKey;
  final BearerAccessTokenReader accessTokenReader;

  AuthContext requireContext(Session session) {
    final secret = session.passwords[passwordKey];
    if (secret == null || secret.isEmpty || secret == '<no value>') {
      throw NexusAuthException.missingAuthSecret(passwordKey);
    }

    final request = session.request;
    if (request == null) {
      throw const NexusAuthException.missingRequest();
    }

    final accessToken = accessTokenReader.read(_requestHeaders(request));
    if (accessToken == null || accessToken.isEmpty) {
      throw const NexusAuthException.missingAccessToken();
    }

    return Rs256AccessTokenVerifier(publicKeyPem: secret).verify(accessToken);
  }

  Map<String, List<String>> _requestHeaders(Request request) {
    return {
      for (final entry in request.headers.entries)
        entry.key.toLowerCase(): entry.value.toList(growable: false),
    };
  }
}
