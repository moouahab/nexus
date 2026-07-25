import 'package:serverpod/serverpod.dart';

import '../constants/auth_claim_names.dart';
import '../domain/auth_result.dart';
import '../domain/authenticated_request.dart';
import 'auth_dependencies.dart';
import 'authenticated_json_route.dart';

class AuthMeRoute extends AuthenticatedJsonRoute {
  AuthMeRoute() : super(methods: const {Method.get, Method.post});

  @override
  Future<AuthResult> executeAuthenticated(
    Session session,
    Request request,
    AuthDependencies dependencies,
    AuthenticatedRequest authenticated,
  ) async {
    return AuthResult(
      identityId: authenticated.identityId,
      authSessionId: authenticated.authSessionId,
      responseHeaders: const {},
      body: {
        AuthClaimNames.subject: authenticated.identityId.toString(),
        AuthClaimNames.sessionId: authenticated.authSessionId.toString(),
        'identityId': authenticated.identityId.toString(),
        'authSessionId': authenticated.authSessionId.toString(),
        'username': authenticated.identity.username,
        'email': authenticated.identity.email,
        'emailVerified': authenticated.identity.emailVerified,
        AuthClaimNames.authenticationMethods: authenticated
            .claims
            .authenticationMethods
            .map((method) => method.name)
            .toList(),
      },
    );
  }
}
