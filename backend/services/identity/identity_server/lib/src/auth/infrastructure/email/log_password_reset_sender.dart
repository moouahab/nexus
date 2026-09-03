import 'package:serverpod/serverpod.dart';

import '../../application/interfaces/password_reset_sender.dart';
import '../../application/services/auth_audit.dart';

class LogPasswordResetSender implements PasswordResetSender {
  const LogPasswordResetSender();

  @override
  Future<void> sendResetCode(
    Session session, {
    required String email,
    required String code,
  }) async {
    AuthAudit.log(
      session,
      event: 'password_reset_code_send',
      outcome: 'success',
      subject: email,
    );

    if (session.serverpod.runMode == ServerpodRunMode.development) {
      session.log('[AuthDev] Password reset code ($email): $code');
    }
  }
}
