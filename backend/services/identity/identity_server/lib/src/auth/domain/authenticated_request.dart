import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart' as protocol;
import 'auth_claims.dart';

class AuthenticatedRequest {
  const AuthenticatedRequest({
    required this.identityId,
    required this.authSessionId,
    required this.claims,
    required this.identity,
    required this.authSession,
  });

  final UuidValue identityId;
  final UuidValue authSessionId;
  final AuthClaims claims;
  final protocol.Identity identity;
  final protocol.AuthSession authSession;
}
