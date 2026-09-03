import 'package:serverpod/serverpod.dart';

import '../domain/auth_result.dart';
import '../domain/authenticated_request.dart';
import 'auth_dependencies.dart';
import 'authenticated_json_route.dart';

class AuthChangeEmailRoute extends AuthenticatedJsonRoute {
  @override
  Future<AuthResult> executeAuthenticated(
    Session session,
    Request request,
    AuthDependencies dependencies,
    AuthenticatedRequest authenticated,
  ) async {
    final headers = requestHeaders(request);
    if (dependencies.csrfProtection.requiresProtection(headers)) {
      dependencies.csrfProtection.requireValid(headers);
    }

    final body = await readJsonBody(request);
    final email = readStringBodyField(body, 'email');

    final identity = await dependencies.changeEmail.execute(
      session,
      identityId: authenticated.identity.id!,
      email: email,
    );

    return AuthResult(
      responseHeaders: dependencies.authCookieService.clearAuthCookies(),
      body: {
        'identityId': identity.id.toString(),
        'email': identity.email,
        'emailVerified': identity.emailVerified,
      },
    );
  }
}
