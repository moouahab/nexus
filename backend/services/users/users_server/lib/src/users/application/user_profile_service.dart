import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

class UserProfileService {
  const UserProfileService();

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
  }) async {
    await _ensureIdentityAvailable(session, identityId);

    return UserProfile.db.insertRow(
      session,
      UserProfile(
        identityId: identityId,
        displayName: _requiredText(displayName, 'displayName'),
        kind: kind,
        status: UserProfileStatus.active,
        primaryPartyId: primaryPartyId,
        email: _normalizeEmail(email),
        avatarUri: _optionalText(avatarUri),
        bio: _optionalText(bio),
        locale: _optionalText(locale),
        timezone: _optionalText(timezone),
        metadata: _normalizeMetadata(metadata),
      ),
    );
  }

  Future<UserProfile> getProfile(Session session, UuidValue userProfileId) {
    return _requiredProfile(session, userProfileId);
  }

  Future<UserProfile> getProfileByIdentity(
    Session session,
    UuidValue identityId,
  ) async {
    final profile = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.identityId.equals(identityId),
    );
    if (profile == null) throw StateError('User profile not found.');
    return profile;
  }

  Future<UserProfile> setPrimaryParty(
    Session session, {
    required UuidValue userProfileId,
    required UuidValue? primaryPartyId,
  }) async {
    final profile = await _requiredProfile(session, userProfileId);
    return UserProfile.db.updateRow(
      session,
      profile.copyWith(
        primaryPartyId: primaryPartyId,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<UserProfile> _requiredProfile(
    Session session,
    UuidValue userProfileId,
  ) async {
    final profile = await UserProfile.db.findById(session, userProfileId);
    if (profile == null) throw StateError('User profile not found.');
    return profile;
  }

  Future<void> _ensureIdentityAvailable(
    Session session,
    UuidValue identityId,
  ) async {
    final existing = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.identityId.equals(identityId),
    );
    if (existing != null) throw StateError('User profile already exists.');
  }

  String _requiredText(String value, String field) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, field, 'Value is required.');
    }
    return normalized;
  }

  String? _optionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String? _normalizeEmail(String? value) {
    return _optionalText(value)?.toLowerCase();
  }

  Map<String, String>? _normalizeMetadata(Map<String, String>? metadata) {
    final normalized = metadata?.map(
      (key, value) => MapEntry(key.trim(), value.trim()),
    );
    normalized?.removeWhere((key, value) => key.isEmpty || value.isEmpty);
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
