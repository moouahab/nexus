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
import 'package:users_client/src/protocol/users/models/user_profile.dart'
    as _i3;
import 'package:users_client/src/protocol/users/models/user_profile_kind.dart'
    as _i4;
import 'protocol.dart' as _i5;

/// {@category Endpoint}
class EndpointUser extends _i1.EndpointRef {
  EndpointUser(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'user';

  _i2.Future<_i3.UserProfile> completeMyProfile({
    required String displayName,
    required _i4.UserProfileKind kind,
    _i1.UuidValue? primaryPartyId,
    String? email,
    String? avatarUri,
    String? bio,
    String? locale,
    String? timezone,
    Map<String, String>? metadata,
  }) => caller.callServerEndpoint<_i3.UserProfile>(
    'user',
    'completeMyProfile',
    {
      'displayName': displayName,
      'kind': kind,
      'primaryPartyId': primaryPartyId,
      'email': email,
      'avatarUri': avatarUri,
      'bio': bio,
      'locale': locale,
      'timezone': timezone,
      'metadata': metadata,
    },
  );

  _i2.Future<_i3.UserProfile> getMyProfile() =>
      caller.callServerEndpoint<_i3.UserProfile>(
        'user',
        'getMyProfile',
        {},
      );

  _i2.Future<_i3.UserProfile> completeProfile({
    required _i1.UuidValue identityId,
    required String displayName,
    required _i4.UserProfileKind kind,
    _i1.UuidValue? primaryPartyId,
    String? email,
    String? avatarUri,
    String? bio,
    String? locale,
    String? timezone,
    Map<String, String>? metadata,
  }) => caller.callServerEndpoint<_i3.UserProfile>(
    'user',
    'completeProfile',
    {
      'identityId': identityId,
      'displayName': displayName,
      'kind': kind,
      'primaryPartyId': primaryPartyId,
      'email': email,
      'avatarUri': avatarUri,
      'bio': bio,
      'locale': locale,
      'timezone': timezone,
      'metadata': metadata,
    },
  );

  _i2.Future<_i3.UserProfile> getProfile(_i1.UuidValue userProfileId) =>
      caller.callServerEndpoint<_i3.UserProfile>(
        'user',
        'getProfile',
        {'userProfileId': userProfileId},
      );

  _i2.Future<_i3.UserProfile> getProfileByIdentity(_i1.UuidValue identityId) =>
      caller.callServerEndpoint<_i3.UserProfile>(
        'user',
        'getProfileByIdentity',
        {'identityId': identityId},
      );

  _i2.Future<_i3.UserProfile> setPrimaryParty({
    required _i1.UuidValue userProfileId,
    required _i1.UuidValue? primaryPartyId,
  }) => caller.callServerEndpoint<_i3.UserProfile>(
    'user',
    'setPrimaryParty',
    {
      'userProfileId': userProfileId,
      'primaryPartyId': primaryPartyId,
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
         _i5.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    user = EndpointUser(this);
  }

  late final EndpointUser user;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {'user': user};

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
