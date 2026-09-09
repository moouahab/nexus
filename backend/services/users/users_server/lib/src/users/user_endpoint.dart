import 'package:serverpod/serverpod.dart';
import 'package:nexus_auth/nexus_auth.dart';

import '../generated/protocol.dart';
import 'application/user_profile_service.dart';

class UserEndpoint extends Endpoint {
  static const _profiles = UserProfileService();
  static const _auth = AuthContextResolver();

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
    final auth = _auth.requireContext(session);
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
    final auth = _auth.requireContext(session);
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
    final auth = _authContextForHttp(session);
    return _profiles.completeProfile(
      session,
      identityId: auth?.identityId ?? identityId,
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
    _ensureOwnProfileForHttp(session, profile);
    return profile;
  }

  Future<UserProfile> getProfileByIdentity(
    Session session,
    UuidValue identityId,
  ) {
    final auth = _authContextForHttp(session);
    if (auth != null && auth.identityId != identityId) {
      throw StateError('User profile access is not allowed.');
    }
    return _profiles.getProfileByIdentity(session, identityId);
  }

  Future<UserProfile> setPrimaryParty(
    Session session, {
    required UuidValue userProfileId,
    required UuidValue? primaryPartyId,
  }) async {
    final profile = await _profiles.getProfile(session, userProfileId);
    _ensureOwnProfileForHttp(session, profile);
    return _profiles.setPrimaryParty(
      session,
      userProfileId: userProfileId,
      primaryPartyId: primaryPartyId,
    );
  }

  AuthContext? _authContextForHttp(Session session) {
    if (session.request == null) return null;
    return _auth.requireContext(session);
  }

  void _ensureOwnProfileForHttp(Session session, UserProfile profile) {
    final auth = _authContextForHttp(session);
    if (auth != null && profile.identityId != auth.identityId) {
      throw StateError('User profile access is not allowed.');
    }
  }
}
