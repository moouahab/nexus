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
import 'package:serverpod/serverpod.dart' as _i1;
import '../users/user_endpoint.dart' as _i2;
import 'package:users_server/src/generated/users/models/user_profile_kind.dart'
    as _i3;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'user': _i2.UserEndpoint()
        ..initialize(
          server,
          'user',
          null,
        ),
    };
    connectors['user'] = _i1.EndpointConnector(
      name: 'user',
      endpoint: endpoints['user']!,
      methodConnectors: {
        'completeMyProfile': _i1.MethodConnector(
          name: 'completeMyProfile',
          params: {
            'displayName': _i1.ParameterDescription(
              name: 'displayName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'kind': _i1.ParameterDescription(
              name: 'kind',
              type: _i1.getType<_i3.UserProfileKind>(),
              nullable: false,
            ),
            'primaryPartyId': _i1.ParameterDescription(
              name: 'primaryPartyId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'avatarUri': _i1.ParameterDescription(
              name: 'avatarUri',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'bio': _i1.ParameterDescription(
              name: 'bio',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'locale': _i1.ParameterDescription(
              name: 'locale',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'timezone': _i1.ParameterDescription(
              name: 'timezone',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'metadata': _i1.ParameterDescription(
              name: 'metadata',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i2.UserEndpoint).completeMyProfile(
                    session,
                    displayName: params['displayName'],
                    kind: params['kind'],
                    primaryPartyId: params['primaryPartyId'],
                    email: params['email'],
                    avatarUri: params['avatarUri'],
                    bio: params['bio'],
                    locale: params['locale'],
                    timezone: params['timezone'],
                    metadata: params['metadata'],
                  ),
        ),
        'getMyProfile': _i1.MethodConnector(
          name: 'getMyProfile',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i2.UserEndpoint).getMyProfile(session),
        ),
        'completeProfile': _i1.MethodConnector(
          name: 'completeProfile',
          params: {
            'identityId': _i1.ParameterDescription(
              name: 'identityId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'displayName': _i1.ParameterDescription(
              name: 'displayName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'kind': _i1.ParameterDescription(
              name: 'kind',
              type: _i1.getType<_i3.UserProfileKind>(),
              nullable: false,
            ),
            'primaryPartyId': _i1.ParameterDescription(
              name: 'primaryPartyId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'avatarUri': _i1.ParameterDescription(
              name: 'avatarUri',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'bio': _i1.ParameterDescription(
              name: 'bio',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'locale': _i1.ParameterDescription(
              name: 'locale',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'timezone': _i1.ParameterDescription(
              name: 'timezone',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'metadata': _i1.ParameterDescription(
              name: 'metadata',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i2.UserEndpoint).completeProfile(
                    session,
                    identityId: params['identityId'],
                    displayName: params['displayName'],
                    kind: params['kind'],
                    primaryPartyId: params['primaryPartyId'],
                    email: params['email'],
                    avatarUri: params['avatarUri'],
                    bio: params['bio'],
                    locale: params['locale'],
                    timezone: params['timezone'],
                    metadata: params['metadata'],
                  ),
        ),
        'getProfile': _i1.MethodConnector(
          name: 'getProfile',
          params: {
            'userProfileId': _i1.ParameterDescription(
              name: 'userProfileId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i2.UserEndpoint).getProfile(
                session,
                params['userProfileId'],
              ),
        ),
        'getProfileByIdentity': _i1.MethodConnector(
          name: 'getProfileByIdentity',
          params: {
            'identityId': _i1.ParameterDescription(
              name: 'identityId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i2.UserEndpoint).getProfileByIdentity(
                    session,
                    params['identityId'],
                  ),
        ),
        'setPrimaryParty': _i1.MethodConnector(
          name: 'setPrimaryParty',
          params: {
            'userProfileId': _i1.ParameterDescription(
              name: 'userProfileId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'primaryPartyId': _i1.ParameterDescription(
              name: 'primaryPartyId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i2.UserEndpoint).setPrimaryParty(
                    session,
                    userProfileId: params['userProfileId'],
                    primaryPartyId: params['primaryPartyId'],
                  ),
        ),
      },
    );
  }
}
