class BearerAccessTokenReader {
  const BearerAccessTokenReader();

  String? read(Map<String, List<String>> headers) {
    final authorization = _firstHeader(headers, 'authorization');
    if (authorization == null) return null;

    final parts = authorization.trim().split(RegExp(r'\s+'));
    if (parts.length != 2) return null;
    if (parts.first.toLowerCase() != 'bearer') return null;
    if (parts.last.isEmpty) return null;

    return parts.last;
  }

  String? _firstHeader(Map<String, List<String>> headers, String name) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == name && entry.value.isNotEmpty) {
        return entry.value.first;
      }
    }

    return null;
  }
}
