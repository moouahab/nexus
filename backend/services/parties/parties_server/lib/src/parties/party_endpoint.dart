import 'package:serverpod/serverpod.dart';
import 'package:nexus_auth/nexus_auth.dart';

import '../generated/protocol.dart';
import 'application/party_authorization.dart';
import 'application/party_service.dart';

class PartyEndpoint extends Endpoint {
  static const _parties = PartyService();
  static const _authorization = PartyAuthorization();

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
    _requireServiceContext(
      session,
      const [PartyAuthorization.membershipWriteScope],
    );
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
    _requireServiceContext(
      session,
      const [PartyAuthorization.membershipWriteScope],
    );
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
    _requireServiceContext(
      session,
      const [PartyAuthorization.membershipReadScope],
    );
    return _parties.listMemberships(
      session,
      userProfileId: userProfileId,
      status: status,
    );
  }

  void _ensureAuthenticatedHttp(Session session) {
    try {
      _authorization.requireUser(session);
    } on NexusAuthException catch (error) {
      throw NotAuthorizedException(
        reason: _authFailureReason(error),
        message: 'Authentication failed.',
      );
    }
  }

  ServiceAuthContext _requireServiceContext(
    Session session,
    Iterable<String> requiredScopes,
  ) {
    try {
      return _authorization.requireService(
        session,
        scopes: requiredScopes,
      );
    } on NexusAuthException catch (error) {
      throw NotAuthorizedException(
        reason: _authFailureReason(error),
        message: 'Authentication failed.',
      );
    }
  }

  AuthenticationFailureReason _authFailureReason(NexusAuthException error) {
    return switch (error.code) {
      NexusAuthExceptionCode.missingAccessToken ||
      NexusAuthExceptionCode.invalidAccessToken =>
        AuthenticationFailureReason.unauthenticated,
      NexusAuthExceptionCode.missingAuthSecret ||
      NexusAuthExceptionCode.missingRequest =>
        AuthenticationFailureReason.insufficientAccess,
    };
  }
}
