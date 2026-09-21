import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../application/party_authorization.dart';
import '../party_endpoint.dart';
import 'party_http_dto.dart';
import 'party_http_json_route.dart';

void registerPartyHttpRoutes(Serverpod pod) {
  final endpoint = PartyEndpoint();
  pod.webServer
    ..addRoute(_PartiesRoute(endpoint), '/parties')
    ..addRoute(_PartyRoute(endpoint), '/parties/:partyId')
    ..addRoute(_MyPartyAccessRoute(endpoint), '/parties/:partyId/my-access')
    ..addRoute(_CreatePartyWithOwnerRoute(), '/parties/with-owner')
    ..addRoute(_JoinPartyRoute(), '/parties/:partyId/memberships')
    ..addRoute(_MembershipsRoute(), '/memberships');
}

final class _PartiesRoute extends PartyHttpJsonRoute {
  _PartiesRoute(this.endpoint)
    : super(methods: const {Method.get, Method.post});

  final PartyEndpoint endpoint;

  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    if (request.method == Method.post) {
      final json = await readJsonObject(request);
      final party = await endpoint.createParty(
        session,
        kind: parseEnum(requiredString(json, 'kind'), PartyKind.values, 'kind'),
        name: requiredString(json, 'name'),
        legalName: optionalString(json, 'legalName'),
        registrationNumber: optionalString(json, 'registrationNumber'),
        country: optionalString(json, 'country'),
        website: optionalString(json, 'website'),
        metadata: optionalMetadata(json),
      );
      return partyJson(party);
    }

    final query = request.url.queryParameters;
    final kind = query['kind'];
    final status = query['status'];
    final results = await endpoint.listParties(
      session,
      kind: kind == null ? null : parseEnum(kind, PartyKind.values, 'kind'),
      status: status == null
          ? null
          : parseEnum(status, PartyStatus.values, 'status'),
      limit: _integer(query['limit'], 'limit', 50),
      offset: _integer(query['offset'], 'offset', 0),
    );
    return {'items': results.map(partyJson).toList(growable: false)};
  }

  int _integer(String? value, String field, int fallback) {
    if (value == null) return fallback;
    final parsed = int.tryParse(value);
    if (parsed == null) {
      throw FormatException('Query "$field" must be an integer.');
    }
    return parsed;
  }
}

final class _PartyRoute extends PartyHttpJsonRoute {
  _PartyRoute(this.endpoint) : super(methods: const {Method.get});

  final PartyEndpoint endpoint;

  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final id = request.pathParameters.raw[#partyId];
    if (id == null) throw const FormatException('Missing partyId.');
    return partyJson(
      await endpoint.getParty(session, parseUuid(id, 'partyId')),
    );
  }
}

final class _MyPartyAccessRoute extends PartyHttpJsonRoute {
  _MyPartyAccessRoute(this.endpoint) : super(methods: const {Method.get});

  final PartyEndpoint endpoint;

  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final id = request.pathParameters.raw[#partyId];
    if (id == null) throw const FormatException('Missing partyId.');
    return endpoint.getMyPartyAccess(
      session,
      parseUuid(id, 'partyId'),
    );
  }
}

final class _CreatePartyWithOwnerRoute extends PartyHttpJsonRoute {
  _CreatePartyWithOwnerRoute() : super(methods: const {Method.post});

  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final context = authorization.requireService(
      session,
      scopes: const [PartyAuthorization.membershipWriteScope],
    );
    final json = await readJsonObject(request);
    final userProfileId = requiredUuid(json, 'userProfileId');
    authorization.requireExactBoundary(context, resources: [userProfileId]);
    final membership = await parties.createPartyWithOwner(
      session,
      userProfileId: userProfileId,
      kind: parseEnum(requiredString(json, 'kind'), PartyKind.values, 'kind'),
      name: requiredString(json, 'name'),
      legalName: optionalString(json, 'legalName'),
      registrationNumber: optionalString(json, 'registrationNumber'),
      country: optionalString(json, 'country'),
      website: optionalString(json, 'website'),
      title: optionalString(json, 'title'),
      metadata: optionalMetadata(json),
    );
    return partyMembershipJson(membership);
  }

  @override
  int get successStatusCode => 201;
}

final class _JoinPartyRoute extends PartyHttpJsonRoute {
  _JoinPartyRoute() : super(methods: const {Method.post});

  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final context = authorization.requireService(
      session,
      scopes: const [PartyAuthorization.membershipWriteScope],
    );
    final partyId = request.pathParameters.raw[#partyId];
    if (partyId == null) throw const FormatException('Missing partyId.');
    final parsedPartyId = parseUuid(partyId, 'partyId');
    authorization.requireExactBoundary(
      context,
      resources: [parsedPartyId],
      tenants: [parsedPartyId],
    );
    final json = await readJsonObject(request);
    final role = optionalString(json, 'role');
    final status = optionalString(json, 'status');
    final membership = await parties.joinParty(
      session,
      userProfileId: requiredUuid(json, 'userProfileId'),
      partyId: parsedPartyId,
      role: role == null
          ? PartyMembershipRole.member
          : parseEnum(role, PartyMembershipRole.values, 'role'),
      status: status == null
          ? PartyMembershipStatus.pending
          : parseEnum(status, PartyMembershipStatus.values, 'status'),
      isPrimary: optionalBool(json, 'isPrimary', false),
      title: optionalString(json, 'title'),
      invitedByIdentityId: optionalUuid(json, 'invitedByIdentityId'),
      metadata: optionalMetadata(json),
    );
    return partyMembershipJson(membership);
  }

  @override
  int get successStatusCode => 201;
}

final class _MembershipsRoute extends PartyHttpJsonRoute {
  _MembershipsRoute() : super(methods: const {Method.get});

  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final context = authorization.requireService(
      session,
      scopes: const [PartyAuthorization.membershipReadScope],
    );
    final query = request.url.queryParameters;
    final userProfileId = query['userProfileId'];
    if (userProfileId == null) {
      throw const FormatException('Query "userProfileId" is required.');
    }
    final parsedUserProfileId = parseUuid(userProfileId, 'userProfileId');
    authorization.requireExactBoundary(
      context,
      resources: [parsedUserProfileId],
    );
    final status = query['status'];
    final results = await parties.listMemberships(
      session,
      userProfileId: parsedUserProfileId,
      status: status == null
          ? null
          : parseEnum(status, PartyMembershipStatus.values, 'status'),
    );
    return {
      'items': results.map(partyMembershipJson).toList(growable: false),
    };
  }
}
