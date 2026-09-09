import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../domain/party_membership_policy.dart';

class PartyService {
  const PartyService({
    PartyMembershipPolicy policy = const PartyMembershipPolicy(),
  }) : _policy = policy;

  final PartyMembershipPolicy _policy;

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
    return Party.db.insertRow(
      session,
      Party(
        kind: kind,
        status: PartyStatus.active,
        name: _requiredText(name, 'name'),
        legalName: _optionalText(legalName),
        registrationNumber: _optionalText(registrationNumber),
        country: _optionalText(country),
        website: _optionalText(website),
        metadata: _normalizeMetadata(metadata),
      ),
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
    return session.db.transaction((transaction) async {
      final party = await Party.db.insertRow(
        session,
        Party(
          kind: kind,
          status: PartyStatus.active,
          name: _requiredText(name, 'name'),
          legalName: _optionalText(legalName),
          registrationNumber: _optionalText(registrationNumber),
          country: _optionalText(country),
          website: _optionalText(website),
          metadata: _normalizeMetadata(metadata),
        ),
        transaction: transaction,
      );

      return PartyMembership.db.insertRow(
        session,
        PartyMembership(
          userProfileId: userProfileId,
          partyId: party.id!,
          role: _policy.initialRoleFor(kind),
          status: PartyMembershipStatus.active,
          isPrimary: true,
          title: _optionalText(title),
        ),
        transaction: transaction,
      );
    });
  }

  Future<Party> getParty(Session session, UuidValue partyId) async {
    final party = await Party.db.findById(session, partyId);
    if (party == null) throw StateError('Party not found.');
    return party;
  }

  Future<List<Party>> listParties(
    Session session, {
    PartyKind? kind,
    PartyStatus? status,
    int limit = 50,
    int offset = 0,
  }) {
    _validatePagination(limit: limit, offset: offset);
    return Party.db.find(
      session,
      where: kind == null && status == null
          ? null
          : (t) {
              Expression<dynamic>? expression;
              if (kind != null) expression = t.kind.equals(kind);
              if (status != null) {
                final statusExpression = t.status.equals(status);
                expression = expression == null
                    ? statusExpression
                    : expression & statusExpression;
              }
              return expression!;
            },
      orderBy: (t) => t.createdAt,
      orderDescending: true,
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
  }) async {
    final party = await getParty(session, partyId);
    _ensureRoleMatchesParty(role: role, partyKind: party.kind);
    await _ensureMembershipAvailable(
      session,
      userProfileId: userProfileId,
      partyId: party.id!,
    );

    if (isPrimary) {
      await _clearPrimaryMemberships(session, userProfileId: userProfileId);
    }

    return PartyMembership.db.insertRow(
      session,
      PartyMembership(
        userProfileId: userProfileId,
        partyId: party.id!,
        role: role,
        status: status,
        isPrimary: isPrimary,
        title: _optionalText(title),
        invitedByIdentityId: invitedByIdentityId,
        metadata: _normalizeMetadata(metadata),
      ),
    );
  }

  Future<List<PartyMembership>> listMemberships(
    Session session, {
    required UuidValue userProfileId,
    PartyMembershipStatus? status,
  }) {
    return PartyMembership.db.find(
      session,
      where: (t) {
        var expression = t.userProfileId.equals(userProfileId);
        if (status != null) expression = expression & t.status.equals(status);
        return expression;
      },
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  Future<void> _ensureMembershipAvailable(
    Session session, {
    required UuidValue userProfileId,
    required UuidValue partyId,
  }) async {
    final existing = await PartyMembership.db.findFirstRow(
      session,
      where: (t) =>
          t.userProfileId.equals(userProfileId) & t.partyId.equals(partyId),
    );
    if (existing != null) throw StateError('Party membership already exists.');
  }

  Future<void> _clearPrimaryMemberships(
    Session session, {
    required UuidValue userProfileId,
  }) async {
    await PartyMembership.db.updateWhere(
      session,
      where: (t) =>
          t.userProfileId.equals(userProfileId) &
          t.status.equals(PartyMembershipStatus.active),
      columnValues: (t) => [
        t.isPrimary(false),
        t.updatedAt(DateTime.now().toUtc()),
      ],
    );
  }

  void _ensureRoleMatchesParty({
    required PartyMembershipRole role,
    required PartyKind partyKind,
  }) {
    if (!_policy.canUseRoleForParty(role: role, partyKind: partyKind)) {
      throw ArgumentError.value(role, 'role', 'Role does not match party.');
    }
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

  Map<String, String>? _normalizeMetadata(Map<String, String>? metadata) {
    final normalized = metadata?.map(
      (key, value) => MapEntry(key.trim(), value.trim()),
    );
    normalized?.removeWhere((key, value) => key.isEmpty || value.isEmpty);
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  void _validatePagination({
    required int limit,
    required int offset,
    int maxLimit = 100,
  }) {
    if (limit < 1 || limit > maxLimit) {
      throw ArgumentError.value(limit, 'limit', 'Invalid page size.');
    }
    if (offset < 0) {
      throw ArgumentError.value(offset, 'offset', 'Invalid offset.');
    }
  }
}
