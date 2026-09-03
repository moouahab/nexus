abstract class AccessTokenReader {
  String? readAccessToken({
    required Map<String, List<String>> headers,
  });
}
