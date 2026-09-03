import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

class AuthAudit {
  const AuthAudit._();

  static void log(
    Session session, {
    required String event,
    required String outcome,
    String? reasonCode,
    UuidValue? identityId,
    UuidValue? authSessionId,
    Object? provider,
    Object? tokenTransport,
    String? subject,
  }) {
    final data = <String, Object?>{
      'event': event,
      'outcome': outcome,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    if (reasonCode != null) data['reasonCode'] = reasonCode;
    if (identityId != null) data['identityId'] = identityId.toString();
    if (authSessionId != null) {
      data['authSessionId'] = authSessionId.toString();
    }
    if (provider != null) data['provider'] = provider.toString();
    if (tokenTransport != null) {
      data['tokenTransport'] = tokenTransport.toString();
    }
    if (subject != null) {
      data['subjectHash'] = _hash(subject);
    }

    session.log('[AuthAudit] ${jsonEncode(data)}');
  }

  static String _hash(String value) {
    final normalized = value.trim().toLowerCase();
    return sha256.convert(utf8.encode(normalized)).toString();
  }
}
