import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:users_server/src/generated/protocol.dart';
import 'package:users_server/src/users/http/user_http_dto.dart';

void main() {
  test('serializes a portable profile without Serverpod metadata', () {
    final profile = UserProfile(
      id: const Uuid().v7obj(),
      identityId: const Uuid().v7obj(),
      displayName: 'Alice',
      kind: UserProfileKind.organizationMember,
      status: UserProfileStatus.active,
      createdAt: DateTime.utc(2026, 9, 18, 12, 30),
      metadata: {'skill': 'security'},
    );

    final json = userProfileJson(profile);

    expect(json['id'], profile.id.toString());
    expect(json['identityId'], profile.identityId.toString());
    expect(json['kind'], 'organizationMember');
    expect(json['createdAt'], '2026-09-18T12:30:00.000Z');
    expect(json['metadata'], {'skill': 'security'});
    expect(json, isNot(contains('__className__')));
  });

  test('omits absent optional values', () {
    final json = userProfileJson(
      UserProfile(
        identityId: const Uuid().v7obj(),
        displayName: 'Bob',
        createdAt: DateTime.utc(2026),
      ),
    );

    expect(json, isNot(contains('email')));
    expect(json, isNot(contains('primaryPartyId')));
    expect(json, isNot(contains('updatedAt')));
  });
}
