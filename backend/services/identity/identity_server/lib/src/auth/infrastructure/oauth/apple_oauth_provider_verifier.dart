import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../application/exceptions/auth_use_case_exception.dart';
import '../../application/interfaces/oauth_provider_verifier.dart';
import 'apple_id_token_verifier.dart';
import 'oauth_http_client.dart';

class AppleOAuthProviderVerifier implements OAuthProviderVerifier {
  AppleOAuthProviderVerifier({
    required String clientId,
    required String clientSecret,
    OAuthHttpClient? httpClient,
    AppleIdTokenVerifier? idTokenVerifier,
  }) : _clientId = clientId,
       _clientSecret = clientSecret,
       _httpClient = httpClient ?? OAuthHttpClient(),
       _idTokenVerifier = idTokenVerifier ?? AppleIdTokenVerifier();

  final String _clientId;
  final String _clientSecret;
  final OAuthHttpClient _httpClient;
  final AppleIdTokenVerifier _idTokenVerifier;

  @override
  protocol.AuthProvider get provider => protocol.AuthProvider.apple;

  @override
  Future<OAuthProviderProfile> verify(
    Session session, {
    required String code,
    required String redirectUri,
    String? codeVerifier,
  }) async {
    final tokenResponse = await _httpClient.postForm(
      Uri.https('appleid.apple.com', '/auth/token'),
      body: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'code': code,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
      },
    );
    final tokenBody = tokenResponse.objectBody;
    if (tokenResponse.statusCode != 200 || tokenBody['error'] != null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    final idToken = tokenBody['id_token'];
    if (idToken is! String || idToken.isEmpty) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    final claims = await _idTokenVerifier.verify(
      idToken: idToken,
      audience: _clientId,
    );
    final subject = claims['sub'];
    if (subject is! String || subject.isEmpty) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    return OAuthProviderProfile(
      provider: provider,
      providerUserId: subject,
      email: _optionalString(claims['email']),
      emailVerified:
          claims['email_verified'] == true ||
          claims['email_verified'] == 'true',
    );
  }

  String? _optionalString(Object? value) {
    if (value is! String) return null;
    final normalized = value.trim().toLowerCase();
    return normalized.isEmpty ? null : normalized;
  }
}
