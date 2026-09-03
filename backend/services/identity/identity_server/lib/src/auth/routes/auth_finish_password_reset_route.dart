import 'package:serverpod/serverpod.dart';

import '../domain/auth_result.dart';
import 'auth_dependencies.dart';
import 'auth_json_route.dart';

class AuthFinishPasswordResetRoute extends AuthJsonRoute {
  @override
  Future<AuthResult> execute(
    Session session,
    Request request,
    AuthDependencies dependencies,
  ) async {
    final body = await readJsonBody(request);
    final email = readStringBodyField(body, 'email');
    final resetCode = readStringBodyField(body, 'resetCode');
    final newPassword = readStringBodyField(body, 'newPassword');

    await dependencies.passwordResetService.finish(
      session,
      email: email,
      code: resetCode,
      newPassword: newPassword,
    );

    return AuthResult(
      responseHeaders: dependencies.authCookieService.clearAuthCookies(),
      body: const {
        'reset': true,
      },
    );
  }
}
