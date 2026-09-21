import 'dart:io';

import '../../application/project_service_token.dart';
import 'http_project_service_token_issuer.dart';

abstract final class ProjectServiceTokenIssuerFactory {
  static ProjectServiceTokenIssuer fromEnvironment([
    Map<String, String>? environment,
  ]) {
    final env = environment ?? Platform.environment;
    final rawUrl = env['IDENTITY_AUTH_BASE_URL'];
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return const UnavailableProjectServiceTokenIssuer();
    }
    final timeoutSeconds =
        int.tryParse(env['IDENTITY_AUTH_TIMEOUT_SECONDS'] ?? '') ?? 5;
    return HttpProjectServiceTokenIssuer(
      identityAuthBaseUri: Uri.parse(rawUrl),
      timeout: Duration(seconds: timeoutSeconds.clamp(2, 15)),
    );
  }
}
