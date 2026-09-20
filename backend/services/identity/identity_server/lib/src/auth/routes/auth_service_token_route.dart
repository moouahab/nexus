import 'package:serverpod/serverpod.dart';

import '../domain/auth_result.dart';
import 'auth_dependencies.dart';
import 'auth_json_route.dart';

class AuthServiceTokenRoute extends AuthJsonRoute {
  @override
  Future<AuthResult> execute(
    Session session,
    Request request,
    AuthDependencies dependencies,
  ) async {
    _rejectBrowserRequest(request);
    final body = await readJsonBody(request);
    final scopes = _readScopes(body);
    final result = dependencies.serviceTokenIssuer.issue(
      serviceName: readStringBodyField(body, 'serviceName'),
      serviceSecret: readStringBodyField(body, 'serviceSecret'),
      audience: readStringBodyField(body, 'audience'),
      scopes: scopes,
    );

    return AuthResult(
      responseHeaders: const {},
      body: {
        'tokenType': 'Bearer',
        'accessToken': result.accessToken,
        'expiresIn': result.expiresIn.inSeconds,
        'serviceName': result.serviceName,
        'audience': result.audience,
        'scopes': result.scopes,
      },
    );
  }

  List<String> _readScopes(Map<String, dynamic> body) {
    final value = body['scopes'];
    if (value is String) {
      return value
          .split(RegExp(r'\s+'))
          .map((scope) => scope.trim())
          .where((scope) => scope.isNotEmpty)
          .toList(growable: false);
    }
    if (value is List) return value.cast<String>();
    throw const FormatException('Expected "scopes" string or list.');
  }

  void _rejectBrowserRequest(Request request) {
    const browserHeaderNames = {
      'cookie',
      'origin',
      'referer',
      'sec-fetch-dest',
      'sec-fetch-mode',
      'sec-fetch-site',
      'sec-fetch-user',
    };

    final isBrowserRequest = request.headers.entries.any(
      (entry) => browserHeaderNames.contains(entry.key.toLowerCase()),
    );
    if (isBrowserRequest) {
      throw const FormatException(
        'Service token endpoint does not accept browser requests.',
      );
    }
  }
}
