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
import '../parties/party_endpoint.dart' as _i2;
import 'package:parties_server/src/generated/parties/models/party_kind.dart'
    as _i3;
import 'package:parties_server/src/generated/parties/models/party_status.dart'
    as _i4;
import 'package:parties_server/src/generated/parties/models/party_membership_role.dart'
    as _i5;
import 'package:parties_server/src/generated/parties/models/party_membership_status.dart'
    as _i6;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'party': _i2.PartyEndpoint()
        ..initialize(
          server,
          'party',
          null,
        ),
    };
    connectors['party'] = _i1.EndpointConnector(
      name: 'party',
      endpoint: endpoints['party']!,
      methodConnectors: {
        'createParty': _i1.MethodConnector(
          name: 'createParty',
          params: {
            'kind': _i1.ParameterDescription(
              name: 'kind',
              type: _i1.getType<_i3.PartyKind>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'legalName': _i1.ParameterDescription(
              name: 'legalName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'registrationNumber': _i1.ParameterDescription(
              name: 'registrationNumber',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'country': _i1.ParameterDescription(
              name: 'country',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'website': _i1.ParameterDescription(
              name: 'website',
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
              ) async => (endpoints['party'] as _i2.PartyEndpoint).createParty(
                session,
                kind: params['kind'],
                name: params['name'],
                legalName: params['legalName'],
                registrationNumber: params['registrationNumber'],
                country: params['country'],
                website: params['website'],
                metadata: params['metadata'],
              ),
        ),
        'createPartyWithOwner': _i1.MethodConnector(
          name: 'createPartyWithOwner',
          params: {
            'userProfileId': _i1.ParameterDescription(
              name: 'userProfileId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'kind': _i1.ParameterDescription(
              name: 'kind',
              type: _i1.getType<_i3.PartyKind>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'legalName': _i1.ParameterDescription(
              name: 'legalName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'registrationNumber': _i1.ParameterDescription(
              name: 'registrationNumber',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'country': _i1.ParameterDescription(
              name: 'country',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'website': _i1.ParameterDescription(
              name: 'website',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'title': _i1.ParameterDescription(
              name: 'title',
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
              ) async => (endpoints['party'] as _i2.PartyEndpoint)
                  .createPartyWithOwner(
                    session,
                    userProfileId: params['userProfileId'],
                    kind: params['kind'],
                    name: params['name'],
                    legalName: params['legalName'],
                    registrationNumber: params['registrationNumber'],
                    country: params['country'],
                    website: params['website'],
                    title: params['title'],
                    metadata: params['metadata'],
                  ),
        ),
        'getParty': _i1.MethodConnector(
          name: 'getParty',
          params: {
            'partyId': _i1.ParameterDescription(
              name: 'partyId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['party'] as _i2.PartyEndpoint).getParty(
                session,
                params['partyId'],
              ),
        ),
        'listParties': _i1.MethodConnector(
          name: 'listParties',
          params: {
            'kind': _i1.ParameterDescription(
              name: 'kind',
              type: _i1.getType<_i3.PartyKind?>(),
              nullable: true,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<_i4.PartyStatus?>(),
              nullable: true,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['party'] as _i2.PartyEndpoint).listParties(
                session,
                kind: params['kind'],
                status: params['status'],
                limit: params['limit'],
                offset: params['offset'],
              ),
        ),
        'joinParty': _i1.MethodConnector(
          name: 'joinParty',
          params: {
            'userProfileId': _i1.ParameterDescription(
              name: 'userProfileId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'partyId': _i1.ParameterDescription(
              name: 'partyId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<_i5.PartyMembershipRole>(),
              nullable: false,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<_i6.PartyMembershipStatus>(),
              nullable: false,
            ),
            'isPrimary': _i1.ParameterDescription(
              name: 'isPrimary',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'invitedByIdentityId': _i1.ParameterDescription(
              name: 'invitedByIdentityId',
              type: _i1.getType<_i1.UuidValue?>(),
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
              ) async => (endpoints['party'] as _i2.PartyEndpoint).joinParty(
                session,
                userProfileId: params['userProfileId'],
                partyId: params['partyId'],
                role: params['role'],
                status: params['status'],
                isPrimary: params['isPrimary'],
                title: params['title'],
                invitedByIdentityId: params['invitedByIdentityId'],
                metadata: params['metadata'],
              ),
        ),
        'listMemberships': _i1.MethodConnector(
          name: 'listMemberships',
          params: {
            'userProfileId': _i1.ParameterDescription(
              name: 'userProfileId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<_i6.PartyMembershipStatus?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['party'] as _i2.PartyEndpoint).listMemberships(
                    session,
                    userProfileId: params['userProfileId'],
                    status: params['status'],
                  ),
        ),
      },
    );
  }
}
