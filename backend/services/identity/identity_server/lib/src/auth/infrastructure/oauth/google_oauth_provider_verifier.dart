import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../application/exceptions/auth_use_case_exception.dart';
import '../../application/interfaces/oauth_provider_verifier.dart';
import 'oauth_http_client.dart';

class GoogleOAuthProviderVerifier implements OAuthProviderVerifier {
  GoogleOAuthProviderVerifier({
    required String clientId,
    required String clientSecret,
    OAuthHttpClient? httpClient,
  }) : _clientId = clientId,
       _clientSecret = clientSecret,
       _httpClient = httpClient ?? OAuthHttpClient();

  final String _clientId;
  final String _clientSecret;
  final OAuthHttpClient _httpClient;

  @override
  protocol.AuthProvider get provider => protocol.AuthProvider.google;

  @override
  Future<OAuthProviderProfile> verify(
    Session session, {
    required String code,
    required String redirectUri,
    String? codeVerifier,
  }) async {
    final tokenResponse = await _httpClient.postForm(
      Uri.https('oauth2.googleapis.com', '/token'),
      body: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'code': code,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
        'code_verifier': ?codeVerifier,
      },
    );
    if (tokenResponse.statusCode != 200) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    final accessToken = tokenResponse.objectBody['access_token'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    final userInfoResponse = await _httpClient.getJson(
      Uri.https('openidconnect.googleapis.com', '/v1/userinfo'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (userInfoResponse.statusCode != 200) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    final subject = userInfoResponse.objectBody['sub'];
    if (subject is! String || subject.isEmpty) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    return OAuthProviderProfile(
      provider: provider,
      providerUserId: subject,
      email: _optionalString(userInfoResponse.objectBody['email']),
      emailVerified: userInfoResponse.objectBody['email_verified'] == true,
    );
  }

  String? _optionalString(Object? value) {
    if (value is! String) return null;
    final normalized = value.trim().toLowerCase();
    return normalized.isEmpty ? null : normalized;
  }
}
