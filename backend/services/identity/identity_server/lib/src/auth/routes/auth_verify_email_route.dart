import 'package:serverpod/serverpod.dart';

import '../domain/auth_result.dart';
import 'auth_dependencies.dart';
import 'auth_json_route.dart';

class AuthVerifyEmailRoute extends AuthJsonRoute {
  @override
  Future<AuthResult> execute(
    Session session,
    Request request,
    AuthDependencies dependencies,
  ) async {
    final body = await readJsonBody(request);
    final identityId = readUuidBodyField(body, 'identityId');
    final verificationCode = readStringBodyField(body, 'verificationCode');

    final identity = await dependencies.emailVerificationService.verify(
      session,
      identityId: identityId,
      code: verificationCode,
    );

    return AuthResult(
      identityId: identity.id,
      authSessionId: null,
      responseHeaders: const {},
      body: {
        'identityId': identity.id.toString(),
        'email': identity.email,
        'emailVerified': identity.emailVerified,
      },
    );
  }
}
