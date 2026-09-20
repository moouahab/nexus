import '../application/tenant_authorization.dart';
import 'http_tenant_authorization.dart';
import 'dart:io';

final class TenantAuthorizationFactory {
  const TenantAuthorizationFactory._();

  static TenantAuthorization fromEnvironment([
    Map<String, String>? environment,
  ]) {
    final env = environment ?? Platform.environment;
    final rawUrl = env['PARTIES_BASE_URL'];
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return const UnavailableTenantAuthorization();
    }
    return HttpTenantAuthorization(baseUri: Uri.parse(rawUrl));
  }
}
