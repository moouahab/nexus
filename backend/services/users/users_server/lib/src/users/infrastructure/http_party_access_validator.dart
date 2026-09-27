import 'dart:convert';
import 'dart:io';

import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';

import '../application/party_access_validator.dart';

final class HttpPartyAccessValidator implements PartyAccessValidator {
  HttpPartyAccessValidator({
    required Uri baseUri,
    this.timeout = const Duration(seconds: 10),
    HttpClient? client,
  }) : baseUri = _validateBaseUri(baseUri),
       _client = client ?? HttpClient();

  final Uri baseUri;
  final Duration timeout;
  final HttpClient _client;

  @override
  Future<bool> canUseParty({
    required UuidValue partyId,
    required String? bearerToken,
  }) async {
    if (bearerToken == null || bearerToken.isEmpty) return false;
    final uri = baseUri.resolve('parties/$partyId/my-access');
    try {
      final request = await _client.getUrl(uri).timeout(timeout);
      request.followRedirects = false;
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $bearerToken',
      );
      request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
      NexusObservability.addOutboundHeaders(request.headers);
      final response = await request.close().timeout(timeout);
      final body = await utf8.decoder.bind(response).join().timeout(timeout);
      if (response.statusCode != HttpStatus.ok) return false;
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> && decoded['allowed'] == true;
    } on Object {
      return false;
    }
  }

  static Uri _validateBaseUri(Uri uri) {
    if (!{'http', 'https'}.contains(uri.scheme) || uri.host.isEmpty) {
      throw ArgumentError.value(uri, 'baseUri', 'Expected an HTTP(S) URI.');
    }
    return uri.path.endsWith('/') ? uri : uri.replace(path: '${uri.path}/');
  }
}
