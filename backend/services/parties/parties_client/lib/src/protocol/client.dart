/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:parties_client/src/protocol/parties/models/party.dart' as _i3;
import 'package:parties_client/src/protocol/parties/models/party_kind.dart'
    as _i4;
import 'package:parties_client/src/protocol/parties/models/party_membership.dart'
    as _i5;
import 'package:parties_client/src/protocol/parties/models/party_status.dart'
    as _i6;
import 'package:parties_client/src/protocol/parties/models/party_membership_role.dart'
    as _i7;
import 'package:parties_client/src/protocol/parties/models/party_membership_status.dart'
    as _i8;
import 'protocol.dart' as _i9;

/// {@category Endpoint}
class EndpointParty extends _i1.EndpointRef {
  EndpointParty(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'party';

  _i2.Future<_i3.Party> createParty({
    required _i4.PartyKind kind,
    required String name,
    String? legalName,
    String? registrationNumber,
    String? country,
    String? website,
    Map<String, String>? metadata,
  }) => caller.callServerEndpoint<_i3.Party>(
    'party',
    'createParty',
    {
      'kind': kind,
      'name': name,
      'legalName': legalName,
      'registrationNumber': registrationNumber,
      'country': country,
      'website': website,
      'metadata': metadata,
    },
  );

  _i2.Future<_i5.PartyMembership> createPartyWithOwner({
    required _i1.UuidValue userProfileId,
    required _i4.PartyKind kind,
    required String name,
    String? legalName,
    String? registrationNumber,
    String? country,
    String? website,
    String? title,
    Map<String, String>? metadata,
  }) => caller.callServerEndpoint<_i5.PartyMembership>(
    'party',
    'createPartyWithOwner',
    {
      'userProfileId': userProfileId,
      'kind': kind,
      'name': name,
      'legalName': legalName,
      'registrationNumber': registrationNumber,
      'country': country,
      'website': website,
      'title': title,
      'metadata': metadata,
    },
  );

  _i2.Future<_i3.Party> getParty(_i1.UuidValue partyId) =>
      caller.callServerEndpoint<_i3.Party>(
        'party',
        'getParty',
        {'partyId': partyId},
      );

  _i2.Future<List<_i3.Party>> listParties({
    _i4.PartyKind? kind,
    _i6.PartyStatus? status,
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<List<_i3.Party>>(
    'party',
    'listParties',
    {
      'kind': kind,
      'status': status,
      'limit': limit,
      'offset': offset,
    },
  );

  _i2.Future<_i5.PartyMembership> joinParty({
    required _i1.UuidValue userProfileId,
    required _i1.UuidValue partyId,
    required _i7.PartyMembershipRole role,
    required _i8.PartyMembershipStatus status,
    required bool isPrimary,
    String? title,
    _i1.UuidValue? invitedByIdentityId,
    Map<String, String>? metadata,
  }) => caller.callServerEndpoint<_i5.PartyMembership>(
    'party',
    'joinParty',
    {
      'userProfileId': userProfileId,
      'partyId': partyId,
      'role': role,
      'status': status,
      'isPrimary': isPrimary,
      'title': title,
      'invitedByIdentityId': invitedByIdentityId,
      'metadata': metadata,
    },
  );

  _i2.Future<List<_i5.PartyMembership>> listMemberships({
    required _i1.UuidValue userProfileId,
    _i8.PartyMembershipStatus? status,
  }) => caller.callServerEndpoint<List<_i5.PartyMembership>>(
    'party',
    'listMemberships',
    {
      'userProfileId': userProfileId,
      'status': status,
    },
  );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i9.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    party = EndpointParty(this);
  }

  late final EndpointParty party;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {'party': party};

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
