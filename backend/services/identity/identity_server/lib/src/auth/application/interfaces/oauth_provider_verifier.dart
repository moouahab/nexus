import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;

class OAuthProviderProfile {
  const OAuthProviderProfile({
    required this.provider,
    required this.providerUserId,
    this.email,
    this.emailVerified = false,
  });

  final protocol.AuthProvider provider;
  final String providerUserId;
  final String? email;
  final bool emailVerified;
}

abstract interface class OAuthProviderVerifier {
  protocol.AuthProvider get provider;

  Future<OAuthProviderProfile> verify(
    Session session, {
    required String code,
    required String redirectUri,
    String? codeVerifier,
  });
}
