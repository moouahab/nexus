import 'dart:convert';
import 'dart:io';

class OAuthHttpResponse {
  const OAuthHttpResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final Object? body;

  Map<String, dynamic> get objectBody {
    final currentBody = body;
    if (currentBody is Map<String, dynamic>) return currentBody;
    throw const FormatException('Expected JSON object from OAuth provider.');
  }

  List<dynamic> get listBody {
    final currentBody = body;
    if (currentBody is List<dynamic>) return currentBody;
    throw const FormatException('Expected JSON list from OAuth provider.');
  }
}

class OAuthHttpClient {
  OAuthHttpClient({
    HttpClient? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? HttpClient() {
    _client.connectionTimeout = timeout;
  }

  final HttpClient _client;
  final Duration timeout;

  Future<OAuthHttpResponse> postForm(
    Uri uri, {
    required Map<String, String> body,
    Map<String, String> headers = const {},
  }) async {
    final request = await _client.postUrl(uri).timeout(timeout);
    request.headers.contentType = ContentType(
      'application',
      'x-www-form-urlencoded',
      charset: 'utf-8',
    );
    _setHeaders(request, headers);
    request.write(
      body.entries
          .map(
            (entry) =>
                '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}',
          )
          .join('&'),
    );

    final response = await request.close().timeout(timeout);
    return _readJsonResponse(response).timeout(timeout);
  }

  Future<OAuthHttpResponse> getJson(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    final request = await _client.getUrl(uri).timeout(timeout);
    _setHeaders(request, headers);
    final response = await request.close().timeout(timeout);
    return _readJsonResponse(response).timeout(timeout);
  }

  Future<OAuthHttpResponse> _readJsonResponse(
    HttpClientResponse response,
  ) async {
    final responseBody = await utf8.decoder.bind(response).join();
    final decoded = responseBody.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(responseBody);

    return OAuthHttpResponse(statusCode: response.statusCode, body: decoded);
  }

  void _setHeaders(HttpClientRequest request, Map<String, String> headers) {
    for (final entry in headers.entries) {
      request.headers.set(entry.key, entry.value);
    }
  }
}
