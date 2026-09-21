import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:nexus_auth/nexus_auth.dart';

import '../../application/project_authorization.dart';

final class HttpProjectAuthorization implements ProjectAuthorization {
  HttpProjectAuthorization({
    required Uri baseUri,
    this.timeout = const Duration(seconds: 10),
    HttpClient? client,
  }) : baseUri = _validateBaseUri(baseUri),
       _client = client ?? HttpClient();

  final Uri baseUri;
  final Duration timeout;
  final HttpClient _client;

  @override
  Future<String?> authorizeProject({
    required UuidValue projectId,
    required UuidValue tenantPartyId,
    UuidValue? identityId,
    String? serviceName,
    String? bearerToken,
  }) async {
    if (bearerToken == null || bearerToken.isEmpty) return null;
    final uri = baseUri.resolve(
      'projects/$projectId/ai-access?tenantPartyId=$tenantPartyId',
    );
    try {
      final request = await _client.getUrl(uri).timeout(timeout);
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $bearerToken',
      );
      request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
      NexusObservability.addOutboundHeaders(request.headers);
      final response = await request.close().timeout(timeout);
      final body = await utf8.decoder.bind(response).join().timeout(timeout);
      if (response.statusCode != HttpStatus.ok) return null;
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic> || decoded['allowed'] != true) {
        return null;
      }
      final grant = decoded['authorizationGrant'];
      return grant is String && grant.isNotEmpty ? grant : null;
    } on Object {
      return null;
    }
  }

  static Uri _validateBaseUri(Uri uri) {
    if (!{'http', 'https'}.contains(uri.scheme) || uri.host.isEmpty) {
      throw ArgumentError.value(uri, 'baseUri', 'Expected an HTTP(S) URI.');
    }
    return uri.path.endsWith('/') ? uri : uri.replace(path: '${uri.path}/');
  }
}
