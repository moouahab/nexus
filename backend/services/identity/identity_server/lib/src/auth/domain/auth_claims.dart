import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../constants/auth_claim_names.dart';
import '../constants/auth_token_defaults.dart';
import '../constants/auth_token_types.dart';

class AuthClaims {
  const AuthClaims({
    required this.subject,
    required this.sessionId,
    required this.issuer,
    required this.audience,
    required this.tokenType,
    required this.issuedAt,
    required this.expiresAt,
    required this.emailVerified,
    required this.authenticationMethods,
  });

  factory AuthClaims.access({
    required UuidValue identityId,
    required UuidValue sessionId,
    required bool emailVerified,
    required List<AuthProvider> authenticationMethods,
    DateTime? issuedAt,
    Duration lifetime = AuthTokenDefaults.accessTokenLifetime,
    String issuer = AuthTokenDefaults.issuer,
    String audience = AuthTokenDefaults.audience,
  }) {
    final now = issuedAt ?? DateTime.now().toUtc();
    return AuthClaims(
      subject: identityId.toString(),
      sessionId: sessionId.toString(),
      issuer: issuer,
      audience: audience,
      tokenType: AuthTokenTypes.access,
      issuedAt: now,
      expiresAt: now.add(lifetime),
      emailVerified: emailVerified,
      authenticationMethods: authenticationMethods,
    );
  }

  factory AuthClaims.fromJson(Map<String, dynamic> json) {
    return AuthClaims(
      subject: json[AuthClaimNames.subject] as String,
      sessionId: json[AuthClaimNames.sessionId] as String,
      issuer: json[AuthClaimNames.issuer] as String,
      audience: json[AuthClaimNames.audience] as String,
      tokenType: json[AuthClaimNames.tokenType] as String,
      issuedAt: _dateTimeFromEpochSeconds(json[AuthClaimNames.issuedAt]),
      expiresAt: _dateTimeFromEpochSeconds(json[AuthClaimNames.expiresAt]),
      emailVerified: json[AuthClaimNames.emailVerified] as bool,
      authenticationMethods:
          (json[AuthClaimNames.authenticationMethods] as List<dynamic>)
              .cast<String>()
              .map(AuthProvider.fromJson)
              .toList(),
    );
  }

  final String subject;
  final String sessionId;
  final String issuer;
  final String audience;
  final String tokenType;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final bool emailVerified;
  final List<AuthProvider> authenticationMethods;

  bool get isExpired => !expiresAt.isAfter(DateTime.now().toUtc());

  UuidValue get identityId => UuidValue.withValidation(subject);

  UuidValue get authSessionId => UuidValue.withValidation(sessionId);

  Map<String, dynamic> toJson() {
    return {
      AuthClaimNames.subject: subject,
      AuthClaimNames.sessionId: sessionId,
      AuthClaimNames.issuer: issuer,
      AuthClaimNames.audience: audience,
      AuthClaimNames.tokenType: tokenType,
      AuthClaimNames.issuedAt: _epochSeconds(issuedAt),
      AuthClaimNames.expiresAt: _epochSeconds(expiresAt),
      AuthClaimNames.emailVerified: emailVerified,
      AuthClaimNames.authenticationMethods: authenticationMethods
          .map((method) => method.name)
          .toList(),
    };
  }

  static DateTime _dateTimeFromEpochSeconds(dynamic value) {
    return DateTime.fromMillisecondsSinceEpoch(
      (value as int) * 1000,
      isUtc: true,
    );
  }

  static int _epochSeconds(DateTime value) {
    return value.toUtc().millisecondsSinceEpoch ~/ 1000;
  }
}
