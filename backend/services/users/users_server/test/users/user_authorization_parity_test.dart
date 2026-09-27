import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:users_server/src/users/application/party_access_validator.dart';
import 'package:users_server/src/users/application/user_profile_service.dart';
import 'package:users_server/src/users/http/user_http_dto.dart';
import 'package:users_server/src/users/http/user_http_json_route.dart';
import 'package:users_server/src/users/user_endpoint.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Users REST/RPC authorization parity', (sessionBuilder, _) {
    const profiles = UserProfileService();
    final userA = UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000101',
    );
    final userB = UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000102',
    );
    final partyA = UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000001',
    );
    final partyB = UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000002',
    );

    test('User A reads only Profile A through REST and RPC', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);
      final profileA = await profiles.completeProfile(
        session,
        identityId: userA,
        displayName: 'User A',
        primaryPartyId: partyA,
      );
      final profileB = await profiles.completeProfile(
        session,
        identityId: userB,
        displayName: 'User B',
        primaryPartyId: partyB,
      );
      final endpoint = UserEndpoint(
        userAuth: _UserAuth(userA),
        partyAccess: _PartyAccess(partyA),
      );

      expect(
        (await endpoint.getProfile(session, profileA.id!)).id,
        profileA.id,
      );
      await expectLater(
        endpoint.getProfile(session, profileB.id!),
        throwsA(isA<NotAuthorizedException>()),
      );

      final allowed = await _ProfileParityRoute(
        endpoint: endpoint,
        profileId: profileA.id!,
        userAuth: _UserAuth(userA),
      ).handleJsonCall(session, _Request(Method.get));
      final denied = await _ProfileParityRoute(
        endpoint: endpoint,
        profileId: profileB.id!,
        userAuth: _UserAuth(userA),
      ).handleJsonCall(session, _Request(Method.get));

      expect((allowed as Response).statusCode, 200);
      expect((denied as Response).statusCode, 403);
    });

    test('User A cannot attach Profile A to Party B via REST or RPC', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);
      final profileA = await profiles.completeProfile(
        session,
        identityId: userA,
        displayName: 'User A',
        primaryPartyId: partyA,
      );
      final endpoint = UserEndpoint(
        userAuth: _UserAuth(userA),
        partyAccess: _PartyAccess(partyA),
      );

      await expectLater(
        endpoint.setPrimaryParty(
          session,
          userProfileId: profileA.id!,
          primaryPartyId: partyB,
        ),
        throwsA(isA<NotAuthorizedException>()),
      );
      final denied = await _PrimaryPartyParityRoute(
        endpoint: endpoint,
        profileId: profileA.id!,
        partyId: partyB,
        userAuth: _UserAuth(userA),
      ).handleJsonCall(session, _Request(Method.put));

      expect((denied as Response).statusCode, 403);
      expect(
        (await profiles.getProfile(session, profileA.id!)).primaryPartyId,
        partyA,
      );
    });
  });
}

final class _ProfileParityRoute extends UserHttpJsonRoute {
  _ProfileParityRoute({
    required this.endpoint,
    required this.profileId,
    required super.userAuth,
  }) : super(methods: const {Method.get});

  final UserEndpoint endpoint;
  final UuidValue profileId;

  @override
  Future<Map<String, dynamic>> execute(
    Session session,
    Request request,
  ) async => userProfileJson(await endpoint.getProfile(session, profileId));
}

final class _PrimaryPartyParityRoute extends UserHttpJsonRoute {
  _PrimaryPartyParityRoute({
    required this.endpoint,
    required this.profileId,
    required this.partyId,
    required super.userAuth,
  }) : super(methods: const {Method.put});

  final UserEndpoint endpoint;
  final UuidValue profileId;
  final UuidValue partyId;

  @override
  Future<Map<String, dynamic>> execute(
    Session session,
    Request request,
  ) async => userProfileJson(
    await endpoint.setPrimaryParty(
      session,
      userProfileId: profileId,
      primaryPartyId: partyId,
    ),
  );
}

final class _PartyAccess implements PartyAccessValidator {
  const _PartyAccess(this.allowedParty);

  final UuidValue allowedParty;

  @override
  Future<bool> canUseParty({
    required UuidValue partyId,
    required String? bearerToken,
  }) async => partyId == allowedParty;
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

final class _Request implements Request {
  _Request(this.method);

  @override
  final Method method;

  @override
  Headers get headers => Headers.fromMap(const {});

  @override
  Uri get url => Uri.parse('http://localhost/v1/users/test');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
