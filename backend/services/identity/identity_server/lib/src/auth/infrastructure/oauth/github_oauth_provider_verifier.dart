import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../application/exceptions/auth_use_case_exception.dart';
import '../../application/interfaces/oauth_provider_verifier.dart';
import 'oauth_http_client.dart';

class GitHubOAuthProviderVerifier implements OAuthProviderVerifier {
  GitHubOAuthProviderVerifier({
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
  protocol.AuthProvider get provider => protocol.AuthProvider.github;

  @override
  Future<OAuthProviderProfile> verify(
    Session session, {
    required String code,
    required String redirectUri,
    String? codeVerifier,
  }) async {
    final tokenResponse = await _httpClient.postForm(
      Uri.https('github.com', '/login/oauth/access_token'),
      body: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'code': code,
        'redirect_uri': redirectUri,
        'code_verifier': ?codeVerifier,
      },
      headers: {'Accept': 'application/json'},
    );
    final tokenBody = tokenResponse.objectBody;
    if (tokenResponse.statusCode != 200 || tokenBody['error'] != null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    final accessToken = tokenBody['access_token'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    final userResponse = await _githubGet('/user', accessToken);
    if (userResponse.statusCode != 200) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    final userBody = userResponse.objectBody;
    final id = userBody['id'];
    if (id == null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    var email = _optionalString(userBody['email']);
    var emailVerified = false;
    final emailsResponse = await _githubGet('/user/emails', accessToken);
    if (emailsResponse.statusCode == 200) {
      final emails = emailsResponse.listBody;
      final primaryVerified = emails.whereType<Map>().where((item) {
        return item['primary'] == true && item['verified'] == true;
      }).firstOrNull;
      email = _optionalString(primaryVerified?['email']) ?? email;
      emailVerified = primaryVerified != null;
    }

    return OAuthProviderProfile(
      provider: provider,
      providerUserId: id.toString(),
      email: email,
      emailVerified: emailVerified,
    );
  }

  Future<OAuthHttpResponse> _githubGet(String path, String accessToken) {
    return _httpClient.getJson(
      Uri.https('api.github.com', path),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );
  }

  String? _optionalString(Object? value) {
    if (value is! String) return null;
    final normalized = value.trim().toLowerCase();
    return normalized.isEmpty ? null : normalized;
  }
}
