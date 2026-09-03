import 'package:serverpod/serverpod.dart';

import '../domain/auth_result.dart';
import 'auth_dependencies.dart';
import 'auth_json_route.dart';

class AuthLogoutRoute extends AuthJsonRoute {
  @override
  Future<AuthResult> execute(
    Session session,
    Request request,
    AuthDependencies dependencies,
  ) {
    final headers = requestHeaders(request);
    if (dependencies.csrfProtection.requiresProtection(headers)) {
      dependencies.csrfProtection.requireValid(headers);
    }

    return dependencies.logout.execute(
      session,
      requestHeaders: headers,
    );
  }
}
