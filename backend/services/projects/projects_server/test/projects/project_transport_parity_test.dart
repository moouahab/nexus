import 'package:nexus_auth/nexus_auth.dart';
import 'package:projects_server/src/projects/application/project_registry_service.dart';
import 'package:projects_server/src/projects/http/project_http_dto.dart';
import 'package:projects_server/src/projects/http/project_http_json_route.dart';
import 'package:projects_server/src/projects/project_endpoint.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Projects REST/RPC authorization parity', (sessionBuilder, _) {
    const registry = ProjectRegistryService();
    final tenantA = UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000001',
    );
    final tenantB = UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000002',
    );
    final userA = UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000101',
    );

    test('User A can read Project A through REST and RPC', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);
      final projectA = await registry.createProject(
        session,
        slug: 'parity-project-a',
        name: 'Parity Project A',
        tenantPartyId: tenantA,
        ownerIdentityId: userA,
      );
      final auth = _UserAuthResolver(userA);
      final endpoint = ProjectEndpoint(userAuth: auth);
      final route = _ProjectParityRoute(
        projectId: projectA.id!,
        projects: endpoint,
        userAuth: auth,
      );

      expect(
        (await endpoint.getProject(session, projectA.id!)).id,
        projectA.id,
      );
      final response = await route.handleJsonCall(
        session,
        _FakeRequest(method: Method.get),
      );
      expect((response as Response).statusCode, 200);
    });

    test('User A is denied Project B through REST and RPC', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);
      final projectB = await registry.createProject(
        session,
        slug: 'parity-project-b',
        name: 'Parity Project B',
        tenantPartyId: tenantB,
      );
      final auth = _UserAuthResolver(userA);
      final endpoint = ProjectEndpoint(userAuth: auth);
      final route = _ProjectParityRoute(
        projectId: projectB.id!,
        projects: endpoint,
        userAuth: auth,
      );

      await expectLater(
        endpoint.getProject(session, projectB.id!),
        throwsA(_concealedNotFound),
      );
      final readResponse = await route.handleJsonCall(
        session,
        _FakeRequest(method: Method.get),
      );
      expect((readResponse as Response).statusCode, 404);

      await expectLater(
        endpoint.updateProjectProfile(
          session,
          projectId: projectB.id!,
          name: 'RPC cross-tenant update',
        ),
        throwsA(_concealedNotFound),
      );
      final writeResponse = await route.handleJsonCall(
        session,
        _FakeRequest(method: Method.patch),
      );
      expect((writeResponse as Response).statusCode, 404);

      final missingProjectId = UuidValue.withValidation(
        '018f0000-0000-7000-8000-000000009999',
      );
      final missingRoute = _ProjectParityRoute(
        projectId: missingProjectId,
        projects: endpoint,
        userAuth: auth,
      );
      await expectLater(
        endpoint.getProject(session, missingProjectId),
        throwsA(_concealedNotFound),
      );
      final missingResponse = await missingRoute.handleJsonCall(
        session,
        _FakeRequest(method: Method.get),
      );
      expect((missingResponse as Response).statusCode, readResponse.statusCode);
      expect(
        (await registry.getProject(session, projectB.id!)).name,
        'Parity Project B',
      );
    });
  });
}

final _concealedNotFound = isA<StateError>().having(
  (error) => error.message,
  'message',
  'Resource not found.',
);

final class _ProjectParityRoute extends ProjectHttpJsonRoute {
  _ProjectParityRoute({
    required this.projectId,
    required ProjectEndpoint projects,
    required super.userAuth,
  }) : super(
         methods: const {Method.get, Method.patch},
         projects: projects,
       );

  final UuidValue projectId;

  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    if (request.method == Method.get) {
      return projectJson(await projects.getProject(session, projectId));
    }
    return projectJson(
      await projects.updateProjectProfile(
        session,
        projectId: projectId,
        name: 'REST cross-tenant update',
      ),
    );
  }
}

final class _UserAuthResolver extends AuthContextResolver {
  const _UserAuthResolver(this.identityId);

  final UuidValue identityId;

  @override
  AuthContext requireContext(Session session) => AuthContext(
    identityId: identityId,
    authSessionId: UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000901',
    ),
    issuer: AuthTokenDefaults.issuer,
    audience: AuthTokenDefaults.audience,
    emailVerified: true,
    authenticationMethods: const ['pwd'],
    issuedAt: DateTime.utc(2026),
    expiresAt: DateTime.utc(2099),
  );
}

final class _FakeRequest implements Request {
  _FakeRequest({required this.method})
    : headers = Headers.fromMap(const {}),
      url = Uri.parse('http://localhost/v1/projects/projects/test');

  @override
  final Method method;

  @override
  final Headers headers;

  @override
  final Uri url;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
