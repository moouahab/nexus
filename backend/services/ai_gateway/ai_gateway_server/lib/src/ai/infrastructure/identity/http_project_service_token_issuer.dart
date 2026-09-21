import 'dart:convert';
import 'dart:io';

import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';

import '../../application/project_service_token.dart';

final class ProjectServiceTokenExchangeException implements Exception {
  const ProjectServiceTokenExchangeException(this.message);

  final String message;

  @override
  String toString() => 'ProjectServiceTokenExchangeException: $message';
}

/// Exchanges AI Gateway client credentials for a project-bound token.
///
/// Credentials come from Serverpod's password store (Vault in containers),
/// never from the request. Identity must register this client for the
/// `projects-service` audience and the `projects.read` scope.
final class HttpProjectServiceTokenIssuer implements ProjectServiceTokenIssuer {
  HttpProjectServiceTokenIssuer({
    required Uri identityAuthBaseUri,
    this.timeout = const Duration(seconds: 5),
    HttpClient? client,
  }) : identityAuthBaseUri = _validateBaseUri(identityAuthBaseUri),
       _client = client ?? HttpClient();

  final Uri identityAuthBaseUri;
  final Duration timeout;
  final HttpClient _client;

  @override
  Future<String> issueReadToken(
    Session session, {
    required UuidValue tenantPartyId,
    required UuidValue projectId,
    UuidValue? delegatedIdentityId,
  }) async {
    final clientId = _requiredPassword(session, 'identityServiceClientId');
    final clientSecret = _requiredPassword(
      session,
      'identityServiceClientSecret',
    );
    final expectedProject = projectId.toString();
    final expectedIdentity = delegatedIdentityId?.toString();

    try {
      final request = await _client
          .postUrl(identityAuthBaseUri.resolve('service-token'))
          .timeout(timeout);
      request
        ..followRedirects = false
        ..maxRedirects = 0;
      request.headers
        ..contentType = ContentType.json
        ..set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
      NexusObservability.addOutboundHeaders(request.headers);
      request.write(
        jsonEncode({
          'serviceName': clientId,
          'serviceSecret': clientSecret,
          'audience': 'projects-service',
          'scopes': const ['projects.read'],
          'globalAccess': false,
          'projectId': expectedProject,
          ...?(expectedIdentity == null
              ? null
              : {'delegatedIdentityId': expectedIdentity}),
        }),
      );
      final response = await request.close().timeout(timeout);
      final body = await utf8.decoder.bind(response).join().timeout(timeout);
      if (response.isRedirect || response.statusCode != HttpStatus.ok) {
        throw ProjectServiceTokenExchangeException(
          'Identity rejected the bounded token request '
          '(status ${response.statusCode}).',
        );
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw const ProjectServiceTokenExchangeException(
          'Identity returned an invalid token response.',
        );
      }
      final value = Map<String, dynamic>.from(decoded);
      final scopes = value['scopes'];
      final token = value['accessToken'];
      final valid =
          token is String &&
          token.trim().isNotEmpty &&
          value['tokenType'] == 'Bearer' &&
          value['serviceName'] == clientId &&
          value['audience'] == 'projects-service' &&
          scopes is List &&
          scopes.length == 1 &&
          scopes.single == 'projects.read' &&
          value['globalAccess'] == false &&
          value['tenantPartyId'] == null &&
          value['projectId'] == expectedProject &&
          value['delegatedIdentityId'] == expectedIdentity;
      if (!valid) {
        throw const ProjectServiceTokenExchangeException(
          'Identity returned a token outside the requested boundary.',
        );
      }
      return token.trim();
    } on ProjectServiceTokenExchangeException {
      rethrow;
    } on Object {
      // Do not include exceptions: network errors can contain credential-bearing
      // URLs in custom clients and must not leak into logs or API responses.
      throw const ProjectServiceTokenExchangeException(
        'Projects service-token exchange failed.',
      );
    }
  }

  static String _requiredPassword(Session session, String name) {
    final value = session.passwords[name]?.trim();
    if (value == null || value.isEmpty) {
      throw ProjectServiceTokenExchangeException(
        'Required service credential "$name" is unavailable.',
      );
    }
    return value;
  }

  static Uri _validateBaseUri(Uri uri) {
    if (!{'http', 'https'}.contains(uri.scheme) || uri.host.isEmpty) {
      throw ArgumentError.value(
        uri,
        'identityAuthBaseUri',
        'Expected an HTTP(S) URI.',
      );
    }
    return uri.path.endsWith('/') ? uri : uri.replace(path: '${uri.path}/');
  }
}
