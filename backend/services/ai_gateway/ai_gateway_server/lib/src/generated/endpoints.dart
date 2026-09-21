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
import '../ai/ai_gateway_endpoint.dart' as _i2;
import 'package:ai_gateway_server/src/generated/future_calls.dart' as _i3;
export 'future_calls.dart' show ServerpodFutureCallsGetter;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'aiGateway': _i2.AiGatewayEndpoint()
        ..initialize(server, 'aiGateway', null),
    };
    connectors['aiGateway'] = _i1.EndpointConnector(
      name: 'aiGateway',
      endpoint: endpoints['aiGateway']!,
      methodConnectors: {
        'health': _i1.MethodConnector(
          name: 'health',
          params: {},
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['aiGateway'] as _i2.AiGatewayEndpoint).health(session),
        ),
        'capabilities': _i1.MethodConnector(
          name: 'capabilities',
          params: {},
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['aiGateway'] as _i2.AiGatewayEndpoint).capabilities(
                session,
              ),
        ),
        'createRun': _i1.MethodConnector(
          name: 'createRun',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'tenantPartyId': _i1.ParameterDescription(
              name: 'tenantPartyId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'capability': _i1.ParameterDescription(
              name: 'capability',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'input': _i1.ParameterDescription(
              name: 'input',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
            'missionId': _i1.ParameterDescription(
              name: 'missionId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'idempotencyKey': _i1.ParameterDescription(
              name: 'idempotencyKey',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['aiGateway'] as _i2.AiGatewayEndpoint).createRun(
                session,
                projectId: params['projectId'],
                tenantPartyId: params['tenantPartyId'],
                capability: params['capability'],
                input: params['input'],
                missionId: params['missionId'],
                idempotencyKey: params['idempotencyKey'],
              ),
        ),
        'getRun': _i1.MethodConnector(
          name: 'getRun',
          params: {
            'runId': _i1.ParameterDescription(
              name: 'runId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['aiGateway'] as _i2.AiGatewayEndpoint).getRun(
                session,
                params['runId'],
              ),
        ),
        'cancelRun': _i1.MethodConnector(
          name: 'cancelRun',
          params: {
            'runId': _i1.ParameterDescription(
              name: 'runId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['aiGateway'] as _i2.AiGatewayEndpoint).cancelRun(
                session,
                params['runId'],
              ),
        ),
      },
    );
  }

  @override
  _i1.FutureCallDispatch? get futureCalls {
    return _i3.FutureCalls();
  }
}
