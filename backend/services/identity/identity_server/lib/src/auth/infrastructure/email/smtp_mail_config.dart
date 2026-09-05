import 'package:serverpod/serverpod.dart';

class SmtpMailConfig {
  const SmtpMailConfig({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    required this.fromAddress,
    required this.fromName,
    required this.supportAddress,
    required this.ssl,
  });

  final String host;
  final int port;
  final String username;
  final String password;
  final String fromAddress;
  final String fromName;
  final String supportAddress;
  final bool ssl;

  static SmtpMailConfig? fromSession(Session session) {
    final host = _optionalPassword(session, 'smtpHost');
    final username = _optionalPassword(session, 'smtpUsername');
    final password = _optionalPassword(session, 'smtpPassword');
    final fromAddress = _optionalPassword(session, 'mailFromAddress');

    if (host == null ||
        username == null ||
        password == null ||
        fromAddress == null) {
      return null;
    }

    final port =
        int.tryParse(
          _optionalPassword(session, 'smtpPort') ?? '',
        ) ??
        587;

    return SmtpMailConfig(
      host: host,
      port: port,
      username: username,
      password: password,
      fromAddress: fromAddress,
      fromName: _optionalPassword(session, 'mailFromName') ?? 'Nexus',
      supportAddress:
          _optionalPassword(session, 'mailSupportAddress') ?? fromAddress,
      ssl: port == 465,
    );
  }

  static String? _optionalPassword(Session session, String key) {
    final value = session.passwords[key]?.trim();
    if (value == null || value.isEmpty || value == '<no value>') return null;
    return value;
  }
}
