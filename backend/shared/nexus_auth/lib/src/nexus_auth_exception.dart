enum NexusAuthExceptionCode {
  missingAccessToken,
  invalidAccessToken,
  missingAuthSecret,
  missingRequest,
}

class NexusAuthException implements Exception {
  const NexusAuthException(this.code, this.message);

  const NexusAuthException.missingAccessToken()
    : this(NexusAuthExceptionCode.missingAccessToken, 'Missing access token.');

  const NexusAuthException.invalidAccessToken(String message)
    : this(NexusAuthExceptionCode.invalidAccessToken, message);

  const NexusAuthException.missingAuthSecret(String key)
    : this(
        NexusAuthExceptionCode.missingAuthSecret,
        'Missing auth secret: $key',
      );

  const NexusAuthException.missingRequest()
    : this(
        NexusAuthExceptionCode.missingRequest,
        'Session has no HTTP request.',
      );

  final NexusAuthExceptionCode code;
  final String message;

  @override
  String toString() => 'NexusAuthException($code): $message';
}
