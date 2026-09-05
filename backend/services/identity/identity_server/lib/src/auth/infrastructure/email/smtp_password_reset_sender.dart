import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:serverpod/serverpod.dart';

import '../../application/interfaces/password_reset_sender.dart';
import '../../application/services/auth_audit.dart';
import 'smtp_mail_config.dart';

class SmtpPasswordResetSender implements PasswordResetSender {
  const SmtpPasswordResetSender(this.config);

  final SmtpMailConfig config;

  @override
  Future<void> sendResetCode(
    Session session, {
    required String email,
    required String code,
  }) async {
    final message = mailer.Message()
      ..from = mailer.Address(config.fromAddress, config.fromName)
      ..recipients.add(email)
      ..subject = 'Reinitialisation de votre mot de passe Nexus'
      ..text =
          '''
Bonjour,

Votre code de reinitialisation Nexus est : $code

Si vous n'avez pas demande cette reinitialisation, vous pouvez ignorer ce message.

Support: ${config.supportAddress}
''';

    await mailer.send(message, _smtpServer());

    AuthAudit.log(
      session,
      event: 'password_reset_code_send',
      outcome: 'success',
      subject: email,
    );
  }

  SmtpServer _smtpServer() {
    return SmtpServer(
      config.host,
      port: config.port,
      username: config.username,
      password: config.password,
      ssl: config.ssl,
    );
  }
}
