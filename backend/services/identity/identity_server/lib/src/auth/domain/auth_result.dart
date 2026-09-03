import 'package:serverpod/serverpod.dart';

import '../constants/auth_token_defaults.dart';

class AuthResult {
  const AuthResult({
    this.identityId,
    this.authSessionId,
    this.body,
    this.accessToken,
    this.refreshToken,
    this.includeTokensInBody = false,
    required this.responseHeaders,
  });

  final UuidValue? identityId;
  final UuidValue? authSessionId;
  final Map<String, dynamic>? body;
  final String? accessToken;
  final String? refreshToken;
  final bool includeTokensInBody;
  final Map<String, List<String>> responseHeaders;

  Map<String, dynamic> responseBody() {
    if (body != null) return body!;

    final responseBody = <String, dynamic>{
      'identityId': identityId?.toString(),
      'authSessionId': authSessionId?.toString(),
    };

    if (includeTokensInBody) {
      responseBody.addAll({
        'tokenType': 'Bearer',
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresIn': AuthTokenDefaults.accessTokenLifetime.inSeconds,
        'refreshExpiresIn': AuthTokenDefaults.refreshTokenLifetime.inSeconds,
      });
    }

    return responseBody;
  }
}
