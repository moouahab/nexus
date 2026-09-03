import 'package:serverpod/serverpod.dart';

import '../domain/auth_result.dart';
import 'auth_dependencies.dart';
import 'auth_json_route.dart';

class AuthRefreshRoute extends AuthJsonRoute {
  @override
  Future<AuthResult> execute(
    Session session,
    Request request,
    AuthDependencies dependencies,
  ) async {
    final body = request.isEmpty
        ? <String, dynamic>{}
        : await readJsonBody(request);
    final headers = requestHeaders(request);
    final refreshToken = readOptionalStringBodyField(body, 'refreshToken');

    if (refreshToken == null) {
      dependencies.csrfProtection.requireValid(headers);
    }

    return dependencies.refreshSession.execute(
      session,
      requestHeaders: headers,
      refreshToken: refreshToken,
      tokenTransport: tokenTransport(request, body: body),
    );
  }
}
