import 'package:ai_gateway_server/src/ai/application/project_authorization.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  test(
    'production default fails closed when Projects is unavailable',
    () async {
      const authorization = UnavailableProjectAuthorization();

      final allowed = await authorization.canUseProject(
        projectId: UuidValue.withValidation(
          '018f0000-0000-7000-8000-000000000001',
        ),
        tenantPartyId: UuidValue.withValidation(
          '018f0000-0000-7000-8000-000000000002',
        ),
        identityId: UuidValue.withValidation(
          '018f0000-0000-7000-8000-000000000003',
        ),
      );

      expect(allowed, isFalse);
    },
  );
}
