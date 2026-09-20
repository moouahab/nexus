import 'package:serverpod/serverpod.dart';
import 'package:nexus_auth/nexus_auth.dart';

import '../generated/protocol.dart';
import 'application/user_profile_service.dart';

class UserEndpoint extends Endpoint {
  static const _profiles = UserProfileService();
  static const _userAuth = AuthContextResolver();
  static const _serviceAuth = AuthContextResolver(audience: 'users-service');
  static const _readScope = 'users.profile.read';
  static const _writeScope = 'users.profile.write';

  Future<UserProfile> completeMyProfile(
    Session session, {
    required String displayName,
    UserProfileKind kind = UserProfileKind.consultant,
    UuidValue? primaryPartyId,
    String? email,
    String? avatarUri,
    String? bio,
    String? locale,
    String? timezone,
    Map<String, String>? metadata,
  }) {
    final auth = _requireAuthContext(session);
    return _profiles.completeProfile(
      session,
      identityId: auth.identityId,
      displayName: displayName,
      kind: kind,
      primaryPartyId: primaryPartyId,
      email: email,
      avatarUri: avatarUri,
      bio: bio,
      locale: locale,
      timezone: timezone,
      metadata: metadata,
    );
  }

  Future<UserProfile> getMyProfile(Session session) {
    final auth = _requireAuthContext(session);
    return _profiles.getProfileByIdentity(session, auth.identityId);
  }

  Future<UserProfile> completeProfile(
    Session session, {
    required UuidValue identityId,
    required String displayName,
    UserProfileKind kind = UserProfileKind.consultant,
    UuidValue? primaryPartyId,
    String? email,
    String? avatarUri,
    String? bio,
    String? locale,
    String? timezone,
    Map<String, String>? metadata,
  }) {
    final caller = _requireCaller(session, serviceScopes: const [_writeScope]);
    return _profiles.completeProfile(
      session,
      identityId: caller.identityId ?? identityId,
      displayName: displayName,
      kind: kind,
      primaryPartyId: primaryPartyId,
      email: email,
      avatarUri: avatarUri,
      bio: bio,
      locale: locale,
      timezone: timezone,
      metadata: metadata,
    );
  }

  Future<UserProfile> getProfile(
    Session session,
    UuidValue userProfileId,
  ) async {
    final profile = await _profiles.getProfile(session, userProfileId);
    _ensureOwnProfile(
      _requireCaller(session, serviceScopes: const [_readScope]),
      profile,
    );
    return profile;
  }

  Future<UserProfile> getProfileByIdentity(
    Session session,
    UuidValue identityId,
  ) {
    final caller = _requireCaller(session, serviceScopes: const [_readScope]);
    if (caller.identityId != null && caller.identityId != identityId) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'User profile access is not allowed.',
      );
    }
    return _profiles.getProfileByIdentity(session, identityId);
  }

  Future<UserProfile> setPrimaryParty(
    Session session, {
    required UuidValue userProfileId,
    required UuidValue? primaryPartyId,
  }) async {
    final profile = await _profiles.getProfile(session, userProfileId);
    _ensureOwnProfile(
      _requireCaller(session, serviceScopes: const [_writeScope]),
      profile,
    );
    return _profiles.setPrimaryParty(
      session,
      userProfileId: userProfileId,
      primaryPartyId: primaryPartyId,
    );
  }

  void _ensureOwnProfile(_UserCaller caller, UserProfile profile) {
    if (caller.identityId != null && profile.identityId != caller.identityId) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'User profile access is not allowed.',
      );
    }
  }

  AuthContext _requireAuthContext(Session session) {
    try {
      return _userAuth.requireContext(session);
    } on NexusAuthException catch (error) {
      throw NotAuthorizedException(
        reason: _authFailureReason(error),
        message: 'Authentication failed.',
      );
    }
  }

  _UserCaller _requireCaller(
    Session session, {
    required Iterable<String> serviceScopes,
  }) {
    try {
      return _UserCaller.user(_userAuth.requireContext(session));
    } on NexusAuthException catch (error) {
      if (error.code != NexusAuthExceptionCode.invalidAccessToken) {
        throw _notAuthorized(error);
      }
      try {
        return _UserCaller.service(
          _serviceAuth.requireServiceContext(
            session,
            requiredScopes: serviceScopes,
          ),
        );
      } on NexusAuthException catch (serviceError) {
        throw _notAuthorized(serviceError);
      }
    }
  }

  NotAuthorizedException _notAuthorized(NexusAuthException error) {
    return NotAuthorizedException(
      reason: _authFailureReason(error),
      message: 'Authentication failed.',
    );
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

class _UserCaller {
  _UserCaller.user(AuthContext context) : identityId = context.identityId;

  _UserCaller.service(ServiceAuthContext _) : identityId = null;

  final UuidValue? identityId;
}
