import 'package:serverpod/serverpod.dart';

import '../domain/auth_result.dart';
import '../domain/authenticated_request.dart';
import 'auth_dependencies.dart';
import 'authenticated_json_route.dart';

class AuthLogoutRoute extends AuthenticatedJsonRoute {
  @override
  Future<AuthResult> executeAuthenticated(
    Session session,
    Request request,
    AuthDependencies dependencies,
    AuthenticatedRequest authenticated,
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
