import 'package:serverpod/serverpod.dart';

import '../domain/auth_result.dart';
import 'auth_dependencies.dart';
import 'auth_json_route.dart';

class AuthStartPasswordResetRoute extends AuthJsonRoute {
  @override
  Future<AuthResult> execute(
    Session session,
    Request request,
    AuthDependencies dependencies,
  ) async {
    final body = await readJsonBody(request);
    final email = readStringBodyField(body, 'email');

    await dependencies.passwordResetService.start(
      session,
      email: email,
    );

    return const AuthResult(
      responseHeaders: {},
      body: {
        'sent': true,
      },
    );
  }
}
