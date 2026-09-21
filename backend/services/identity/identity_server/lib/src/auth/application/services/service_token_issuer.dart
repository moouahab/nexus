import 'dart:convert';

import '../exceptions/auth_use_case_exception.dart';
import '../interfaces/service_client_registry.dart';
import '../interfaces/service_token_service.dart';
import '../../constants/auth_token_defaults.dart';
import '../../domain/service_auth_claims.dart';

class ServiceTokenIssueResult {
  const ServiceTokenIssueResult({
    required this.accessToken,
    required this.serviceName,
    required this.audience,
    required this.scopes,
    required this.expiresIn,
    required this.globalAccess,
    this.tenantPartyId,
    this.projectId,
    this.resourceId,
    this.delegatedIdentityId,
  });

  final String accessToken;
  final String serviceName;
  final String audience;
  final List<String> scopes;
  final Duration expiresIn;
  final bool globalAccess;
  final String? tenantPartyId;
  final String? projectId;
  final String? resourceId;
  final String? delegatedIdentityId;
}

class ServiceTokenIssuer {
  const ServiceTokenIssuer({
    required ServiceClientRegistry clientRegistry,
    required ServiceTokenService tokenService,
    Duration tokenLifetime = AuthTokenDefaults.serviceTokenLifetime,
  }) : _clientRegistry = clientRegistry,
       _tokenService = tokenService,
       _tokenLifetime = tokenLifetime;

  final ServiceClientRegistry _clientRegistry;
  final ServiceTokenService _tokenService;
  final Duration _tokenLifetime;

  ServiceTokenIssueResult issue({
    required String serviceName,
    required String serviceSecret,
    required String audience,
    required List<String> scopes,
    bool globalAccess = false,
    String? tenantPartyId,
    String? projectId,
    String? resourceId,
    String? delegatedIdentityId,
  }) {
    // This issuer authenticates the registered client and constrains the shape
    // of the token, but it does not prove that the client may choose a specific
    // dynamic UUID. Callers must be trusted for the selected boundary value.
    // TODO(security): accept a short-lived delegation grant signed by the
    // resource authority (for Projects, after its own user authorization).
    final client = _clientRegistry.findByServiceName(serviceName);
    if (client == null || !_constantTimeEquals(client.secret, serviceSecret)) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidCredentials,
      );
    }

    if (!client.allowsAudience(audience) || !client.allowsScopes(scopes)) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidCredentials,
      );
    }

    if (globalAccess && !client.allowGlobalAccess) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidCredentials,
      );
    }
    final boundaryCount = [
      tenantPartyId,
      projectId,
      resourceId,
    ].where((value) => value != null).length;
    if ((globalAccess && boundaryCount != 0) ||
        (!globalAccess && boundaryCount != 1)) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidCredentials,
      );
    }

    final claims = ServiceAuthClaims.service(
      serviceName: client.serviceName,
      audience: audience,
      scopes: scopes,
      lifetime: _tokenLifetime,
      globalAccess: globalAccess,
      tenantPartyId: tenantPartyId,
      projectId: projectId,
      resourceId: resourceId,
      delegatedIdentityId: delegatedIdentityId,
    );

    return ServiceTokenIssueResult(
      accessToken: _tokenService.createServiceToken(claims),
      serviceName: claims.serviceName,
      audience: claims.audience,
      scopes: claims.scopes,
      expiresIn: _tokenLifetime,
      globalAccess: claims.globalAccess,
      tenantPartyId: claims.tenantPartyId,
      projectId: claims.projectId,
      resourceId: claims.resourceId,
      delegatedIdentityId: claims.delegatedIdentityId,
    );
  }

  static bool _constantTimeEquals(String left, String right) {
    final leftBytes = utf8.encode(left);
    final rightBytes = utf8.encode(right);
    if (leftBytes.length != rightBytes.length) return false;

    var difference = 0;
    for (var index = 0; index < leftBytes.length; index++) {
      difference |= leftBytes[index] ^ rightBytes[index];
    }
    return difference == 0;
  }
}
