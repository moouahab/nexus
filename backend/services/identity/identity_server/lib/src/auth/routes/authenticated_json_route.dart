import 'package:serverpod/serverpod.dart';

import '../application/exceptions/authentication_required_exception.dart';
import '../domain/auth_result.dart';
import '../domain/authenticated_request.dart';
import 'auth_dependencies.dart';
import 'auth_json_route.dart';

abstract class AuthenticatedJsonRoute extends AuthJsonRoute {
  AuthenticatedJsonRoute({super.methods});

  Future<AuthResult> executeAuthenticated(
    Session session,
    Request request,
    AuthDependencies dependencies,
    AuthenticatedRequest authenticated,
  );

  @override
  Future<AuthResult> execute(
    Session session,
    Request request,
    AuthDependencies dependencies,
  ) async {
    final authenticated = await dependencies.requireAuth.fromHeaders(
      session,
      headers: requestHeaders(request),
    );

    return executeAuthenticated(
      session,
      request,
      dependencies,
      authenticated,
    );
  }

  @override
  Response authenticationRequiredResponse(
    AuthenticationRequiredException exception,
  ) {
    final statusCode = switch (exception.code) {
      AuthenticationRequiredExceptionCode.identityNotActive => 403,
      AuthenticationRequiredExceptionCode.missingAccessToken => 401,
      AuthenticationRequiredExceptionCode.invalidAccessToken => 401,
      AuthenticationRequiredExceptionCode.sessionNotFound => 401,
      AuthenticationRequiredExceptionCode.identityNotFound => 401,
    };

    return jsonResponse(
      {'error': exception.code.name},
      statusCode: statusCode,
    );
  }
}
