import 'package:projects_server/src/generated/protocol.dart';
import 'package:projects_server/src/projects/http/project_http_dto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  test('project JSON is portable and excludes server filesystem paths', () {
    final project = Project(
      id: UuidValue.withValidation('018f0000-0000-7000-8000-000000000001'),
      slug: 'portable-api',
      name: 'Portable API',
      tenantPartyId: UuidValue.withValidation(
        '018f0000-0000-7000-8000-000000000002',
      ),
      workspacePath: '/srv/private/workspace',
      archivePath: '/srv/private/archive',
      tags: ['api'],
      createdAt: DateTime.parse('2026-09-18T12:00:00+02:00'),
    );

    final json = projectJson(project);

    expect(json['id'], '018f0000-0000-7000-8000-000000000001');
    expect(json['createdAt'], '2026-09-18T10:00:00.000Z');
    expect(json, isNot(contains('workspacePath')));
    expect(json, isNot(contains('archivePath')));
    expect(json, isNot(contains('__className__')));
  });

  test('participant JSON does not embed the database relation', () {
    final participant = ProjectParticipant(
      id: UuidValue.withValidation('018f0000-0000-7000-8000-000000000003'),
      projectId: UuidValue.withValidation(
        '018f0000-0000-7000-8000-000000000001',
      ),
      role: ProjectParticipantRole.nexusContributor,
      project: Project(slug: 'embedded', name: 'Must not leak'),
      createdAt: DateTime.utc(2026, 9, 18),
    );

    final json = participantJson(participant);

    expect(json, isNot(contains('project')));
    expect(json['role'], 'nexusContributor');
  });
}
