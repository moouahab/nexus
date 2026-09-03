enum AuthTokenTransport {
  cookie,
  body;

  static AuthTokenTransport parse(String? value) {
    final normalized = value?.trim().toLowerCase();
    return switch (normalized) {
      null || '' || 'cookie' => AuthTokenTransport.cookie,
      'body' || 'bearer' => AuthTokenTransport.body,
      _ => throw const FormatException('Invalid auth token transport.'),
    };
  }
}
