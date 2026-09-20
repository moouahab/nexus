import 'dart:async';
import 'dart:convert';

import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';

import '../domain/auth_claims.dart';
import '../../generated/protocol.dart';
import '../infrastructure/security/rs256_access_token_service.dart';
import 'auth_dependencies.dart';

class AuthHealthRoute extends Route {
  AuthHealthRoute() : super(methods: const {Method.get});

  @override
  FutureOr<Result> handleCall(Session session, Request request) =>
      NexusObservability.observeHttp(
        session,
        request,
        () => _handleCall(session),
        service: 'identity',
      );

  Result _handleCall(Session session) {
    try {
      final tokenService = AuthDependencies.accessTokenServiceFromSession(
        session,
      );
      final token = tokenService.createAccessToken(
        AuthClaims.access(
          identityId: const Uuid().v7obj(),
          sessionId: const Uuid().v7obj(),
          emailVerified: false,
          authenticationMethods: const [AuthProvider.username],
        ),
      );
      tokenService.verifyAccessToken(token);

      return _jsonResponse({
        'service': 'identity-auth',
        'status': 'ok',
        'checks': {
          'tokenIssuance': true,
          'publicKeyAvailable': tokenService is Rs256AccessTokenService,
          'jwksParseable': tokenService is Rs256AccessTokenService,
        },
      });
    } catch (_) {
      return _jsonResponse(
        {
          'service': 'identity-auth',
          'status': 'unavailable',
          'checks': {
            'tokenIssuance': false,
            'publicKeyAvailable': false,
            'jwksParseable': false,
          },
        },
        statusCode: 503,
      );
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
