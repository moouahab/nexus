import 'dart:async';
import 'dart:convert';

import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';

import '../infrastructure/security/rs256_access_token_service.dart';
import 'auth_dependencies.dart';

class AuthJwksRoute extends Route {
  AuthJwksRoute() : super(methods: const {Method.get});

  @override
  FutureOr<Result> handleCall(Session session, Request request) =>
      NexusObservability.observeHttp(
        session,
        request,
        () => _handleCall(session),
        service: 'identity',
      );

  Result _handleCall(Session session) {
    final tokenService = _accessTokenService(session);
    if (tokenService == null) {
      return _jsonResponse(
        {
          'error': 'jwks_not_available',
        },
        statusCode: 503,
      );
    }

    if (tokenService is! Rs256AccessTokenService) {
      return _jsonResponse(
        {
          'error': 'jwks_not_available',
        },
        statusCode: 503,
      );
    }

    return _jsonResponse({
      'keys': [tokenService.jwk()],
    });
  }

  Object? _accessTokenService(Session session) {
    try {
      return AuthDependencies.accessTokenServiceFromSession(
        session,
      );
    } catch (_) {
      return null;
    }
  }

  Response _jsonResponse(
    Map<String, dynamic> body, {
    int statusCode = 200,
  }) {
    return Response(
      statusCode,
      body: Body.fromString(jsonEncode(body), mimeType: MimeType.json),
      headers: Headers.fromMap(NexusObservability.responseHeaders()),
    );
  }
}
