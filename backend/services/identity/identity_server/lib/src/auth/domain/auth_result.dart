import 'package:serverpod/serverpod.dart';

class AuthResult {
  const AuthResult({
    this.identityId,
    this.authSessionId,
    required this.responseHeaders,
  });

  final UuidValue? identityId;
  final UuidValue? authSessionId;
  final Map<String, List<String>> responseHeaders;
}
