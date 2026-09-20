import 'dart:io';

import '../../application/project_authorization.dart';
import 'http_project_authorization.dart';

abstract final class ProjectAuthorizationFactory {
  static ProjectAuthorization fromEnvironment([
    Map<String, String>? environment,
  ]) {
    final env = environment ?? Platform.environment;
    final rawUrl = env['PROJECTS_BASE_URL'];
    if (rawUrl == null || rawUrl.isEmpty) {
      return const UnavailableProjectAuthorization();
    }
    final seconds = int.tryParse(env['PROJECTS_TIMEOUT_SECONDS'] ?? '') ?? 10;
    return HttpProjectAuthorization(
      baseUri: Uri.parse(rawUrl),
      timeout: Duration(seconds: seconds.clamp(2, 60)),
    );
  }
}
