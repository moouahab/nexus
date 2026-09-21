import 'package:nexus_auth/nexus_auth.dart';
import 'package:test/test.dart';

void main() {
  const codec = ProjectAuthorizationGrantCodec(secret: 'grant-secret');

  test('round trips a project authorization grant', () {
    final token = codec.issue(
      projectId: 'project-1',
      tenantPartyId: 'tenant-1',
      identityId: 'identity-1',
    );
    final grant = codec.verify(token);
    expect(grant.projectId, 'project-1');
    expect(grant.tenantPartyId, 'tenant-1');
    expect(grant.identityId, 'identity-1');
  });

  test('rejects a grant signed with another key', () {
    final token = codec.issue(
      projectId: 'project-1',
      tenantPartyId: 'tenant-1',
      identityId: 'identity-1',
    );
    expect(
      () => const ProjectAuthorizationGrantCodec(
        secret: 'other-secret',
      ).verify(token),
      throwsFormatException,
    );
  });
}
