import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../user_endpoint.dart';
import 'user_http_dto.dart';
import 'user_http_json_route.dart';

void registerUserHttpRoutes(Serverpod pod) {
  final endpoint = UserEndpoint();
  pod.webServer
    ..addRoute(_MyProfileRoute(endpoint), '/me')
    ..addRoute(_ProfilesRoute(endpoint), '/profiles')
    ..addRoute(_ProfileRoute(endpoint), '/profiles/:profileId')
    ..addRoute(
      _ProfileByIdentityRoute(endpoint),
      '/profiles/by-identity/:identityId',
    )
    ..addRoute(
      _PrimaryPartyRoute(endpoint),
      '/profiles/:profileId/primary-party',
    );
}

UserProfileKind _profileKind(Map<String, dynamic> body) {
  final value = body['kind'];
  if (value == null) return UserProfileKind.consultant;
  if (value is! String) {
    throw const FormatException('Field "kind" must be a string.');
  }
  return UserProfileKind.values.firstWhere(
    (kind) => kind.name == value,
    orElse: () => throw const FormatException('Unsupported profile kind.'),
  );
}

abstract class _EndpointRoute extends UserHttpJsonRoute {
  _EndpointRoute(this.endpoint, {required super.methods});

  final UserEndpoint endpoint;

  UuidValue pathUuid(Request request, Symbol name, String field) {
    final value = request.pathParameters.raw[name];
    if (value == null) throw FormatException('Missing $field.');
    return parseUuid(value, field);
  }

  Future<UserProfile> complete(
    Session session,
    Map<String, dynamic> body, {
    UuidValue? identityId,
    bool currentUser = false,
  }) {
    final arguments = (
      displayName: requiredString(body, 'displayName'),
      kind: _profileKind(body),
      primaryPartyId: optionalUuid(body, 'primaryPartyId'),
      email: optionalString(body, 'email'),
      avatarUri: optionalString(body, 'avatarUri'),
      bio: optionalString(body, 'bio'),
      locale: optionalString(body, 'locale'),
      timezone: optionalString(body, 'timezone'),
      metadata: optionalMetadata(body, 'metadata'),
    );
    if (currentUser) {
      return endpoint.completeMyProfile(
        session,
        displayName: arguments.displayName,
        kind: arguments.kind,
        primaryPartyId: arguments.primaryPartyId,
        email: arguments.email,
        avatarUri: arguments.avatarUri,
        bio: arguments.bio,
        locale: arguments.locale,
        timezone: arguments.timezone,
        metadata: arguments.metadata,
      );
    }
    return endpoint.completeProfile(
      session,
      identityId: identityId ?? requiredUuid(body, 'identityId'),
      displayName: arguments.displayName,
      kind: arguments.kind,
      primaryPartyId: arguments.primaryPartyId,
      email: arguments.email,
      avatarUri: arguments.avatarUri,
      bio: arguments.bio,
      locale: arguments.locale,
      timezone: arguments.timezone,
      metadata: arguments.metadata,
    );
  }
}

final class _MyProfileRoute extends _EndpointRoute {
  _MyProfileRoute(super.endpoint)
    : super(methods: const {Method.get, Method.put});

  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final profile = request.method == Method.get
        ? await endpoint.getMyProfile(session)
        : await complete(
            session,
            await readJsonObject(request),
            currentUser: true,
          );
    return userProfileJson(profile);
  }
}

final class _ProfilesRoute extends _EndpointRoute {
  _ProfilesRoute(super.endpoint) : super(methods: const {Method.post});

  @override
  int get successStatusCode => 201;

  @override
  Future<Map<String, dynamic>> execute(
    Session session,
    Request request,
  ) async =>
      userProfileJson(await complete(session, await readJsonObject(request)));
}

final class _ProfileRoute extends _EndpointRoute {
  _ProfileRoute(super.endpoint) : super(methods: const {Method.get});

  @override
  Future<Map<String, dynamic>> execute(
    Session session,
    Request request,
  ) async => userProfileJson(
    await endpoint.getProfile(
      session,
      pathUuid(request, #profileId, 'profileId'),
    ),
  );
}

final class _ProfileByIdentityRoute extends _EndpointRoute {
  _ProfileByIdentityRoute(super.endpoint) : super(methods: const {Method.get});

  @override
  Future<Map<String, dynamic>> execute(
    Session session,
    Request request,
  ) async => userProfileJson(
    await endpoint.getProfileByIdentity(
      session,
      pathUuid(request, #identityId, 'identityId'),
    ),
  );
}

final class _PrimaryPartyRoute extends _EndpointRoute {
  _PrimaryPartyRoute(super.endpoint) : super(methods: const {Method.put});

  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final body = await readJsonObject(request);
    return userProfileJson(
      await endpoint.setPrimaryParty(
        session,
        userProfileId: pathUuid(request, #profileId, 'profileId'),
        primaryPartyId: optionalUuid(body, 'primaryPartyId'),
      ),
    );
  }
}
