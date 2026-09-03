import 'package:serverpod/serverpod.dart';

import '../domain/auth_result.dart';
import 'auth_dependencies.dart';
import 'auth_json_route.dart';

class AuthLoginRoute extends AuthJsonRoute {
  @override
  Future<AuthResult> execute(
    Session session,
    Request request,
    AuthDependencies dependencies,
  ) async {
    final body = await readJsonBody(request);

    return dependencies.loginWithUsername.execute(
      session,
      username: readStringBodyField(body, 'username'),
      password: readStringBodyField(body, 'password'),
      tokenTransport: tokenTransport(request, body: body),
    );
  }
}
