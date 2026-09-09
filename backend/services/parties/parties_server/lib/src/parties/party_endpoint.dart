import 'package:serverpod/serverpod.dart';
import 'package:nexus_auth/nexus_auth.dart';

import '../generated/protocol.dart';
import 'application/party_service.dart';

class PartyEndpoint extends Endpoint {
  static const _parties = PartyService();
  static const _auth = AuthContextResolver();

  Future<Party> createParty(
    Session session, {
    required PartyKind kind,
    required String name,
    String? legalName,
    String? registrationNumber,
    String? country,
    String? website,
    Map<String, String>? metadata,
  }) {
    _ensureAuthenticatedHttp(session);
    return _parties.createParty(
      session,
      kind: kind,
      name: name,
      legalName: legalName,
      registrationNumber: registrationNumber,
      country: country,
      website: website,
      metadata: metadata,
    );
  }

  Future<PartyMembership> createPartyWithOwner(
    Session session, {
    required UuidValue userProfileId,
    required PartyKind kind,
    required String name,
    String? legalName,
    String? registrationNumber,
    String? country,
    String? website,
    String? title,
    Map<String, String>? metadata,
  }) {
    _ensureInternalCall(session);
    return _parties.createPartyWithOwner(
      session,
      userProfileId: userProfileId,
      kind: kind,
      name: name,
      legalName: legalName,
      registrationNumber: registrationNumber,
      country: country,
      website: website,
      title: title,
      metadata: metadata,
    );
  }

  Future<Party> getParty(Session session, UuidValue partyId) {
    _ensureAuthenticatedHttp(session);
    return _parties.getParty(session, partyId);
  }

  Future<List<Party>> listParties(
    Session session, {
    PartyKind? kind,
    PartyStatus? status,
    int limit = 50,
    int offset = 0,
  }) {
    _ensureAuthenticatedHttp(session);
    return _parties.listParties(
      session,
      kind: kind,
      status: status,
      limit: limit,
      offset: offset,
    );
  }

  Future<PartyMembership> joinParty(
    Session session, {
    required UuidValue userProfileId,
    required UuidValue partyId,
    PartyMembershipRole role = PartyMembershipRole.member,
    PartyMembershipStatus status = PartyMembershipStatus.pending,
    bool isPrimary = false,
    String? title,
    UuidValue? invitedByIdentityId,
    Map<String, String>? metadata,
  }) {
    _ensureInternalCall(session);
    return _parties.joinParty(
      session,
      userProfileId: userProfileId,
      partyId: partyId,
      role: role,
      status: status,
      isPrimary: isPrimary,
      title: title,
      invitedByIdentityId: invitedByIdentityId,
      metadata: metadata,
    );
  }

  Future<List<PartyMembership>> listMemberships(
    Session session, {
    required UuidValue userProfileId,
    PartyMembershipStatus? status,
  }) {
    _ensureInternalCall(session);
    return _parties.listMemberships(
      session,
      userProfileId: userProfileId,
      status: status,
    );
  }

  void _ensureAuthenticatedHttp(Session session) {
    if (session.request == null) return;
    _auth.requireContext(session);
  }

  void _ensureInternalCall(Session session) {
    if (session.request == null) return;
    throw StateError(
      'Party membership operations require a trusted service boundary.',
    );
  }
}
