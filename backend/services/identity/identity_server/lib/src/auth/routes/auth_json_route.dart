import 'dart:async';
import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../application/exceptions/auth_use_case_exception.dart';
import '../domain/auth_result.dart';
import 'auth_dependencies.dart';

abstract class AuthJsonRoute extends Route {
  AuthJsonRoute() : super(methods: const {Method.post});

  Future<AuthResult> execute(
    Session session,
    Request request,
    AuthDependencies dependencies,
  );

  @override
  FutureOr<Result> handleCall(Session session, Request request) async {
    try {
      final result = await execute(
        session,
        request,
        AuthDependencies.fromSession(session),
      );

      return jsonResponse(
        {
          'identityId': result.identityId?.toString(),
          'authSessionId': result.authSessionId?.toString(),
        },
        headers: result.responseHeaders,
      );
    } on AuthUseCaseException catch (exception) {
      return _authErrorResponse(exception);
    } on FormatException {
      return jsonResponse(
        {'error': 'invalid_request'},
        statusCode: 400,
      );
    }
  }

  Future<Map<String, dynamic>> readJsonBody(Request request) async {
    if (request.isEmpty) return {};

    final decoded = jsonDecode(await request.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON object.');
    }

    return decoded;
  }

  Map<String, List<String>> requestHeaders(Request request) {
    return {
      for (final entry in request.headers.entries)
        entry.key: entry.value.toList(),
    };
  }

  Response jsonResponse(
    Map<String, dynamic> body, {
    int statusCode = 200,
    Map<String, List<String>> headers = const {},
  }) {
    return Response(
      statusCode,
      body: Body.fromString(jsonEncode(body), mimeType: MimeType.json),
      headers: Headers.fromMap(headers),
    );
  }

  Response _authErrorResponse(AuthUseCaseException exception) {
    final statusCode = switch (exception.code) {
      AuthUseCaseExceptionCode.invalidCredentials => 401,
      AuthUseCaseExceptionCode.missingRefreshToken => 401,
      AuthUseCaseExceptionCode.invalidRefreshToken => 401,
      AuthUseCaseExceptionCode.identityNotActive => 403,
      AuthUseCaseExceptionCode.identityAlreadyExists => 409,
      AuthUseCaseExceptionCode.usernameAlreadyExists => 409,
      AuthUseCaseExceptionCode.tooManyAttempts => 429,
      AuthUseCaseExceptionCode.identityNotFound => 500,
      AuthUseCaseExceptionCode.missingGeneratedId => 500,
    };

    return jsonResponse(
      {'error': exception.code.name},
      statusCode: statusCode,
    );
  }
}
