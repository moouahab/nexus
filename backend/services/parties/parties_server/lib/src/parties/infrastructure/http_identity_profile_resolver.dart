import 'dart:convert';
import 'dart:io';

import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';

import '../application/party_access.dart';

final class HttpIdentityProfileResolver implements IdentityProfileResolver {
  HttpIdentityProfileResolver({
    HttpClient? client,
    Uri? usersBaseUri,
    this.timeout = const Duration(seconds: 3),
  }) : _client = client ?? HttpClient(),
       _usersBaseUri =
           usersBaseUri ??
           Uri.parse(
             Platform.environment['NEXUS_USERS_BASE_URL'] ??
                 'http://kong:8000/v1/users',
           );

  final HttpClient _client;
  final Uri _usersBaseUri;
  final Duration timeout;

  @override
  Future<UuidValue?> findProfileId(
    Session session,
    UuidValue identityId,
  ) async {
    String? authorization;
    final incomingRequest = session.request;
    if (incomingRequest == null) return null;
    for (final entry in incomingRequest.headers.entries) {
      if (entry.key.toLowerCase() == HttpHeaders.authorizationHeader &&
          entry.value.isNotEmpty) {
        authorization = entry.value.first;
        break;
      }
    }
    if (authorization == null || authorization.isEmpty) return null;
    final uri = _usersBaseUri.resolve(
      '${_usersBaseUri.path.endsWith('/') ? '' : '/'}profiles/by-identity/$identityId',
    );
    final request = await _client.getUrl(uri).timeout(timeout);
    request.followRedirects = false;
    request.headers.set(HttpHeaders.authorizationHeader, authorization);
    NexusObservability.addOutboundHeaders(request.headers);
    final response = await request.close().timeout(timeout);
    if (response.isRedirect || response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      return null;
    }
    final decoded = jsonDecode(await utf8.decoder.bind(response).join());
    if (decoded is! Map<String, dynamic> || decoded['id'] is! String) {
      return null;
    }
    try {
      return UuidValue.withValidation(decoded['id'] as String);
    } on Object {
      return null;
    }
  }
}
