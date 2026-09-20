import 'dart:async';
import 'dart:convert';

import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';

import '../application/exceptions/authentication_required_exception.dart';
import '../application/exceptions/auth_use_case_exception.dart';
import '../application/services/auth_audit.dart';
import '../domain/auth_result.dart';
import '../domain/auth_token_transport.dart';
import 'auth_dependencies.dart';

abstract class AuthJsonRoute extends Route {
  AuthJsonRoute({super.methods = const {Method.post}});

  Future<AuthResult> execute(
    Session session,
    Request request,
    AuthDependencies dependencies,
  );

  @override
  FutureOr<Result> handleCall(Session session, Request request) =>
      NexusObservability.observeHttp(
        session,
        request,
        () => _handleCall(session, request),
        service: 'identity',
      );

  Future<Result> _handleCall(Session session, Request request) async {
    try {
      _requireAllowedOrigin(session, request);

      final result = await execute(
        session,
        request,
        AuthDependencies.fromSession(session),
      );

      return jsonResponse(
        result.responseBody(),
        headers: result.responseHeaders,
      );
    } on AuthUseCaseException catch (exception) {
      return _authErrorResponse(exception);
    } on AuthenticationRequiredException catch (exception) {
      return authenticationRequiredResponse(exception);
    } on FormatException {
      return jsonResponse(
        {'error': 'invalid_request'},
        statusCode: 400,
      );
    }
  }

  void _requireAllowedOrigin(Session session, Request request) {
    final origin = _firstHeader(request, 'origin');
    if (origin == null || origin.isEmpty) return;

    final parsedOrigin = Uri.tryParse(origin);
    if (parsedOrigin == null ||
        !parsedOrigin.hasScheme ||
        parsedOrigin.host.isEmpty) {
      throw const FormatException('Invalid Origin header.');
    }

    final allowedOrigins = _allowedOrigins(session);
    if (!allowedOrigins.contains(_originKey(parsedOrigin))) {
      AuthAudit.log(
        session,
        event: 'auth_origin',
        outcome: 'blocked',
        reasonCode: 'origin_not_allowed',
        subject: origin,
      );
      throw const FormatException('Origin is not allowed.');
    }
  }

  Set<String> _allowedOrigins(Session session) {
    final origins = <String>{};
    final configuredOrigins = session.passwords['authAllowedOrigins'];
    if (configuredOrigins != null && configuredOrigins.trim().isNotEmpty) {
      for (final origin in configuredOrigins.split(',')) {
        final parsed = Uri.tryParse(origin.trim());
        if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) {
          origins.add(_originKey(parsed));
        }
      }
    }

    final webConfig = session.serverpod.config.webServer;
    if (webConfig != null) {
      origins.add(
        _originKey(
          Uri(
            scheme: webConfig.publicScheme,
            host: webConfig.publicHost,
            port: webConfig.publicPort,
          ),
        ),
      );
    }

    return origins;
  }

  String _originKey(Uri origin) {
    final hasDefaultPort =
        (origin.scheme == 'https' && origin.port == 443) ||
        (origin.scheme == 'http' && origin.port == 80);
    final port = hasDefaultPort ? '' : ':${origin.port}';
    return '${origin.scheme}://${origin.host.toLowerCase()}$port';
  }

  Future<Map<String, dynamic>> readJsonBody(Request request) async {
    if (request.isEmpty) return {};

    final decoded = jsonDecode(await request.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON object.');
    }

    return decoded;
  }

  String readStringBodyField(
    Map<String, dynamic> body,
    String fieldName,
  ) {
    final value = body[fieldName];
    if (value is! String || value.isEmpty) {
      throw FormatException('Expected non-empty string field "$fieldName".');
    }

    return value;
  }

  String? readOptionalStringBodyField(
    Map<String, dynamic> body,
    String fieldName,
  ) {
    final value = body[fieldName];
    if (value == null) return null;
    if (value is! String || value.isEmpty) {
      throw FormatException('Expected string field "$fieldName".');
    }

    return value;
  }

  UuidValue readUuidBodyField(
    Map<String, dynamic> body,
    String fieldName,
  ) {
    final value = readStringBodyField(body, fieldName);
    try {
      return UuidValueJsonExtension.fromJson(value);
    } on FormatException {
      rethrow;
    } catch (_) {
      throw FormatException('Expected UUID field "$fieldName".');
    }
  }

  AuthTokenTransport tokenTransport(
    Request request, {
    Map<String, dynamic> body = const {},
  }) {
    final headerValue = _firstHeader(request, 'x-auth-token-transport');
    final bodyValue = readOptionalStringBodyField(body, 'tokenTransport');
    final transport = AuthTokenTransport.parse(headerValue ?? bodyValue);

    if (transport == AuthTokenTransport.body &&
        _hasBrowserRequestHeaders(request)) {
      throw const FormatException(
        'Body token transport is not allowed from browser requests.',
      );
    }

    return transport;
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
      headers: Headers.fromMap(NexusObservability.responseHeaders(headers)),
    );
  }

  String? _firstHeader(Request request, String name) {
    for (final entry in request.headers.entries) {
      if (entry.key.toLowerCase() == name && entry.value.isNotEmpty) {
        return entry.value.first;
      }
    }

    return null;
  }

  bool _hasBrowserRequestHeaders(Request request) {
    const browserHeaderNames = {
      'cookie',
      'origin',
      'referer',
      'sec-fetch-dest',
      'sec-fetch-mode',
      'sec-fetch-site',
      'sec-fetch-user',
    };

    return request.headers.entries.any(
      (entry) => browserHeaderNames.contains(entry.key.toLowerCase()),
    );
  }

  Response authenticationRequiredResponse(
    AuthenticationRequiredException exception,
  ) {
    return jsonResponse(
      {'error': exception.code.name},
      statusCode: 401,
    );
  }

  Response _authErrorResponse(AuthUseCaseException exception) {
    final statusCode = switch (exception.code) {
      AuthUseCaseExceptionCode.invalidCredentials => 401,
      AuthUseCaseExceptionCode.missingRefreshToken => 401,
      AuthUseCaseExceptionCode.invalidRefreshToken => 401,
      AuthUseCaseExceptionCode.identityNotActive => 403,
      AuthUseCaseExceptionCode.invalidOAuthCredentials => 401,
      AuthUseCaseExceptionCode.identityAlreadyExists => 409,
      AuthUseCaseExceptionCode.usernameAlreadyExists => 409,
      AuthUseCaseExceptionCode.emailAlreadyExists => 409,
      AuthUseCaseExceptionCode.invalidUsername => 400,
      AuthUseCaseExceptionCode.invalidEmail => 400,
      AuthUseCaseExceptionCode.invalidOAuthProvider => 400,
      AuthUseCaseExceptionCode.weakPassword => 400,
      AuthUseCaseExceptionCode.passwordConfirmationMismatch => 400,
      AuthUseCaseExceptionCode.missingEmail => 400,
      AuthUseCaseExceptionCode.invalidEmailVerificationCode => 401,
      AuthUseCaseExceptionCode.invalidPasswordResetCode => 401,
      AuthUseCaseExceptionCode.tooManyAttempts => 429,
      AuthUseCaseExceptionCode.invalidCsrfToken => 403,
      AuthUseCaseExceptionCode.identityNotFound => 500,
      AuthUseCaseExceptionCode.oauthProviderNotConfigured => 400,
      AuthUseCaseExceptionCode.missingGeneratedId => 500,
    };

    return jsonResponse(
      {'error': exception.code.name},
      statusCode: statusCode,
    );
  }
}
