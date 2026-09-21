import 'package:serverpod/serverpod.dart';
import 'package:nexus_auth/nexus_auth.dart';

import '../generated/protocol.dart';
import 'application/party_authorization.dart';
import 'application/party_access.dart';
import 'application/party_service.dart';
import 'infrastructure/http_identity_profile_resolver.dart';

class PartyEndpoint extends Endpoint {
  PartyEndpoint({
    AuthContextResolver userAuth = const AuthContextResolver(),
    AuthContextResolver serviceAuth = const AuthContextResolver(
      audience: 'parties-service',
    ),
    IdentityProfileResolver? profiles,
  }) : _userAuth = userAuth,
       _serviceAuth = serviceAuth,
       _profiles = profiles ?? HttpIdentityProfileResolver();

  static const _parties = PartyService();
  static const _access = PartyAccessService();
  final AuthContextResolver _userAuth;
  final AuthContextResolver _serviceAuth;
  final IdentityProfileResolver _profiles;

  Future<Party> createParty(
    Session session, {
    required PartyKind kind,
    required String name,
    String? legalName,
    String? registrationNumber,
    String? country,
    String? website,
    Map<String, String>? metadata,
  }) async {
    final auth = _requireUserContext(session);
    final profileId = await _profiles.findProfileId(session, auth.identityId);
    if (profileId == null) throw StateError('User profile not found.');
    final membership = await _parties.createPartyWithOwner(
      session,
      userProfileId: profileId,
      kind: kind,
      name: name,
      legalName: legalName,
      registrationNumber: registrationNumber,
      country: country,
      website: website,
      metadata: metadata,
    );
    return _parties.getParty(session, membership.partyId);
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
    final context = _requireServiceContext(
      session,
      const [PartyAuthorization.membershipWriteScope],
    );
    _requireServiceBoundary(context, resources: [userProfileId]);
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

  Future<Party> getParty(Session session, UuidValue partyId) async {
    final auth = _requireUserContext(session);
    await _access.requireIdentityCanAccessParty(
      session,
      identityId: auth.identityId,
      partyId: partyId,
      profiles: _profiles,
    );
    return _parties.getParty(session, partyId);
  }

  Future<List<Party>> listParties(
    Session session, {
    PartyKind? kind,
    PartyStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final auth = _requireUserContext(session);
    return _access.listPartiesForIdentity(
      session,
      identityId: auth.identityId,
      profiles: _profiles,
      kind: kind,
      status: status,
      limit: limit,
      offset: offset,
    );
  }

  Future<Map<String, dynamic>> getMyPartyAccess(
    Session session,
    UuidValue partyId,
  ) async {
    final auth = _requireUserContext(session);
    return (await _access.accessForIdentity(
      session,
      identityId: auth.identityId,
      partyId: partyId,
      profiles: _profiles,
    )).toJson();
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
    final context = _requireServiceContext(
      session,
      const [PartyAuthorization.membershipWriteScope],
    );
    _requireServiceBoundary(
      context,
      resources: [partyId],
      tenants: [partyId],
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
    final context = _requireServiceContext(
      session,
      const [PartyAuthorization.membershipReadScope],
    );
    _requireServiceBoundary(context, resources: [userProfileId]);
    return _parties.listMemberships(
      session,
      userProfileId: userProfileId,
      status: status,
    );
  }

  AuthContext _requireUserContext(Session session) {
    try {
      return _userAuth.requireContext(session);
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
      return _serviceAuth.requireServiceContext(
        session,
        requiredScopes: requiredScopes,
      );
    } on NexusAuthException catch (error) {
      throw NotAuthorizedException(
        reason: _authFailureReason(error),
        message: 'Authentication failed.',
      );
    }
  }

  void _requireServiceBoundary(
    ServiceAuthContext context, {
    required Iterable<UuidValue> resources,
    Iterable<UuidValue> tenants = const [],
  }) {
    try {
      const PartyAuthorization().requireExactBoundary(
        context,
        resources: resources,
        tenants: tenants,
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
