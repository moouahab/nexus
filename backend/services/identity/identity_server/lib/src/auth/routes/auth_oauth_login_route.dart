import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart' as protocol;
import '../domain/auth_result.dart';
import 'auth_dependencies.dart';
import 'auth_json_route.dart';

class AuthOAuthLoginRoute extends AuthJsonRoute {
  @override
  Future<AuthResult> execute(
    Session session,
    Request request,
    AuthDependencies dependencies,
  ) async {
    final body = await readJsonBody(request);

    return dependencies.loginWithOAuth.execute(
      session,
      provider: _readProvider(readStringBodyField(body, 'provider')),
      code: readStringBodyField(body, 'code'),
      redirectUri: readStringBodyField(body, 'redirectUri'),
      codeVerifier: readOptionalStringBodyField(body, 'codeVerifier'),
      tokenTransport: tokenTransport(request, body: body),
    );
  }

  protocol.AuthProvider _readProvider(String value) {
    return switch (value.trim().toLowerCase()) {
      'google' => protocol.AuthProvider.google,
      'github' => protocol.AuthProvider.github,
      'apple' => protocol.AuthProvider.apple,
      _ => throw const FormatException('Invalid OAuth provider.'),
    };
  }
}
