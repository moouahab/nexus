import 'package:serverpod/serverpod.dart';

import '../../application/interfaces/email_verification_sender.dart';
import '../../application/services/auth_audit.dart';

class LogEmailVerificationSender implements EmailVerificationSender {
  const LogEmailVerificationSender();

  @override
  Future<void> sendVerificationCode(
    Session session, {
    required String email,
    required String code,
  }) async {
    AuthAudit.log(
      session,
      event: 'email_verification_code_send',
      outcome: 'success',
      subject: email,
    );

    if (session.serverpod.runMode == ServerpodRunMode.development) {
      session.log('[AuthDev] Email verification code ($email): $code');
    }
  }
}
