import 'package:parties_server/src/generated/protocol.dart';
import 'package:parties_server/src/parties/http/party_http_dto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  test('party DTO uses portable UUID and UTC timestamp strings', () {
    final id = const Uuid().v7obj();
    final createdAt = DateTime.utc(2026, 9, 19, 10, 30);
    final json = partyJson(
      Party(
        id: id,
        kind: PartyKind.company,
        status: PartyStatus.active,
        name: 'Example',
        createdAt: createdAt,
      ),
    );

    expect(json['id'], id.toString());
    expect(json['createdAt'], createdAt.toIso8601String());
    expect(json['kind'], 'company');
    expect(json['status'], 'active');
  });

  test('membership DTO does not expose Serverpod persistence metadata', () {
    final json = partyMembershipJson(
      PartyMembership(
        id: const Uuid().v7obj(),
        userProfileId: const Uuid().v7obj(),
        partyId: const Uuid().v7obj(),
        role: PartyMembershipRole.member,
        status: PartyMembershipStatus.active,
        isPrimary: false,
        createdAt: DateTime.utc(2026, 9, 19),
      ),
    );

    expect(json, isNot(contains('tableName')));
    expect(json, isNot(contains('_i1')));
  });
}
