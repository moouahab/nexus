import 'package:serverpod/serverpod.dart';

import '../domain/auth_result.dart';
import 'auth_dependencies.dart';
import 'auth_json_route.dart';

class AuthResendEmailVerificationRoute extends AuthJsonRoute {
  @override
  Future<AuthResult> execute(
    Session session,
    Request request,
    AuthDependencies dependencies,
  ) async {
    final body = await readJsonBody(request);
    final identityId = readUuidBodyField(body, 'identityId');

    await dependencies.emailVerificationService.resend(
      session,
      identityId: identityId,
    );

    return const AuthResult(
      responseHeaders: {},
      body: {
        'sent': true,
      },
    );
  }
}
