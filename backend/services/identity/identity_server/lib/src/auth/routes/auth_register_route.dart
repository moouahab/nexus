import 'package:serverpod/serverpod.dart';

import '../domain/auth_result.dart';
import 'auth_dependencies.dart';
import 'auth_json_route.dart';

class AuthRegisterRoute extends AuthJsonRoute {
  @override
  Future<AuthResult> execute(
    Session session,
    Request request,
    AuthDependencies dependencies,
  ) async {
    final body = await readJsonBody(request);

    return dependencies.registerWithUsername.execute(
      session,
      username: body['username'] as String,
      password: body['password'] as String,
      email: body['email'] as String?,
    );
  }
}
