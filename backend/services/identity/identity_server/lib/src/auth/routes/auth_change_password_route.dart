import 'package:serverpod/serverpod.dart';

import '../domain/auth_result.dart';
import '../domain/authenticated_request.dart';
import 'auth_dependencies.dart';
import 'authenticated_json_route.dart';

class AuthChangePasswordRoute extends AuthenticatedJsonRoute {
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
    final currentPassword = readStringBodyField(body, 'currentPassword');
    final newPassword = readStringBodyField(body, 'newPassword');

    await dependencies.changePassword.execute(
      session,
      identityId: authenticated.identity.id!,
      currentPassword: currentPassword,
      newPassword: newPassword,
      email: authenticated.identity.email,
    );

    return AuthResult(
      responseHeaders: dependencies.authCookieService.clearAuthCookies(),
      body: const {
        'changed': true,
      },
    );
  }
}
