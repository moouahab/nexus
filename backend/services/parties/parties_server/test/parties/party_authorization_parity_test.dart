import 'package:nexus_auth/nexus_auth.dart';
import 'package:parties_server/src/generated/protocol.dart';
import 'package:parties_server/src/parties/application/party_access.dart';
import 'package:parties_server/src/parties/application/party_service.dart';
import 'package:parties_server/src/parties/http/party_http_dto.dart';
import 'package:parties_server/src/parties/http/party_http_json_route.dart';
import 'package:parties_server/src/parties/party_endpoint.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Parties authorization parity', (sessionBuilder, _) {
    const service = PartyService();
    final userA = UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000101',
    );
    final profileA = UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000111',
    );

    test('active member reads own Party through REST and RPC only', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);
      final own = await service.createPartyWithOwner(
        session,
        userProfileId: profileA,
        kind: PartyKind.company,
        name: 'Tenant A',
      );
      final foreign = await service.createParty(
        session,
        kind: PartyKind.company,
        name: 'Tenant B',
      );
      final auth = _UserAuth(userA);
      final endpoint = PartyEndpoint(
        userAuth: auth,
        profiles: _Profiles({userA: profileA}),
      );

      expect((await endpoint.getParty(session, own.partyId)).name, 'Tenant A');
      expect(
        await endpoint.listParties(session),
        hasLength(1),
      );
      await expectLater(
        endpoint.getParty(session, foreign.id!),
        throwsA(_concealedNotFound),
      );

      final allowed = await _PartyParityRoute(
        endpoint: endpoint,
        partyId: own.partyId,
        userAuth: auth,
      ).handleJsonCall(session, _Request());
      final denied = await _PartyParityRoute(
        endpoint: endpoint,
        partyId: foreign.id!,
        userAuth: auth,
      ).handleJsonCall(session, _Request());
      final missing = await _PartyParityRoute(
        endpoint: endpoint,
        partyId: const Uuid().v7obj(),
        userAuth: auth,
      ).handleJsonCall(session, _Request());

      expect((allowed as Response).statusCode, 200);
      expect((denied as Response).statusCode, 404);
      expect((missing as Response).statusCode, denied.statusCode);
    });

    test(
      'pending membership grants no access and roles map management',
      () async {
        final session = sessionBuilder.build();
        addTearDown(session.close);
        final party = await service.createParty(
          session,
          kind: PartyKind.company,
          name: 'Tenant roles',
        );
        await service.joinParty(
          session,
          userProfileId: profileA,
          partyId: party.id!,
          role: PartyMembershipRole.member,
          status: PartyMembershipStatus.pending,
        );
        const access = PartyAccessService();
        expect(
          (await access.accessForProfile(
            session,
            userProfileId: profileA,
            partyId: party.id!,
          )).allowed,
          isFalse,
        );
        expect(
          PartyAccessService.managerRoles,
          {PartyMembershipRole.owner, PartyMembershipRole.admin},
        );
      },
    );
  });
}

final _concealedNotFound = isA<StateError>().having(
  (error) => error.message,
  'message',
  'Party not found.',
);

final class _Profiles implements IdentityProfileResolver {
  const _Profiles(this.values);
  final Map<UuidValue, UuidValue> values;

  @override
  Future<UuidValue?> findProfileId(
    Session session,
    UuidValue identityId,
  ) async => values[identityId];
}

final class _UserAuth extends AuthContextResolver {
  const _UserAuth(this.identityId);
  final UuidValue identityId;

  @override
  AuthContext requireContext(Session session) => AuthContext(
    identityId: identityId,
    authSessionId: const Uuid().v7obj(),
    issuer: AuthTokenDefaults.issuer,
    audience: AuthTokenDefaults.audience,
    emailVerified: true,
    authenticationMethods: const ['pwd'],
    issuedAt: DateTime.utc(2026),
    expiresAt: DateTime.utc(2099),
  );
}

final class _PartyParityRoute extends PartyHttpJsonRoute {
  _PartyParityRoute({
    required this.endpoint,
    required this.partyId,
    required super.userAuth,
  }) : super(methods: const {Method.get});

  final PartyEndpoint endpoint;
  final UuidValue partyId;

  @override
  Future<Map<String, dynamic>> execute(
    Session session,
    Request request,
  ) async => partyJson(await endpoint.getParty(session, partyId));
}

final class _Request implements Request {
  @override
  Method get method => Method.get;

  @override
  Headers get headers => Headers.fromMap(const {});

  @override
  Uri get url => Uri.parse('http://localhost/v1/parties/parties/test');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
