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
import 'package:ai_gateway_client/src/protocol/ai/models/ai_gateway_health.dart'
    as _i3;
import 'package:ai_gateway_client/src/protocol/ai/models/ai_capability.dart'
    as _i4;
import 'package:ai_gateway_client/src/protocol/ai/models/ai_run.dart' as _i5;
import 'protocol.dart' as _i6;

/// {@category Endpoint}
class EndpointAiGateway extends _i1.EndpointRef {
  EndpointAiGateway(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'aiGateway';

  _i2.Future<_i3.AiGatewayHealth> health() =>
      caller.callServerEndpoint<_i3.AiGatewayHealth>(
        'aiGateway',
        'health',
        {},
      );

  _i2.Future<List<_i4.AiCapability>> capabilities() =>
      caller.callServerEndpoint<List<_i4.AiCapability>>(
        'aiGateway',
        'capabilities',
        {},
      );

  _i2.Future<_i5.AiRun> createRun({
    required _i1.UuidValue projectId,
    required _i1.UuidValue tenantPartyId,
    required String capability,
    Map<String, String>? input,
    _i1.UuidValue? missionId,
    String? idempotencyKey,
  }) => caller.callServerEndpoint<_i5.AiRun>(
    'aiGateway',
    'createRun',
    {
      'projectId': projectId,
      'tenantPartyId': tenantPartyId,
      'capability': capability,
      'input': input,
      'missionId': missionId,
      'idempotencyKey': idempotencyKey,
    },
  );

  _i2.Future<_i5.AiRun> getRun(_i1.UuidValue runId) =>
      caller.callServerEndpoint<_i5.AiRun>(
        'aiGateway',
        'getRun',
        {'runId': runId},
      );

  _i2.Future<_i5.AiRun> cancelRun(_i1.UuidValue runId) =>
      caller.callServerEndpoint<_i5.AiRun>(
        'aiGateway',
        'cancelRun',
        {'runId': runId},
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
         _i6.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    aiGateway = EndpointAiGateway(this);
  }

  late final EndpointAiGateway aiGateway;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'aiGateway': aiGateway,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
