import 'package:serverpod/serverpod.dart';

class AuthResult {
  const AuthResult({
    this.identityId,
    this.authSessionId,
    this.body,
    required this.responseHeaders,
  });

  final UuidValue? identityId;
  final UuidValue? authSessionId;
  final Map<String, dynamic>? body;
  final Map<String, List<String>> responseHeaders;

  Map<String, dynamic> responseBody() {
    return body ??
        {
          'identityId': identityId?.toString(),
          'authSessionId': authSessionId?.toString(),
        };
  }
}
