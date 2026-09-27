import 'dart:convert';
import 'dart:io';

import 'package:ai_gateway_server/src/ai/domain/reasoning_models.dart';
import 'package:ai_gateway_server/src/ai/application/tools/nexus_tool.dart';
import 'package:ai_gateway_server/src/ai/infrastructure/tools/projects/project_evidence_tool.dart';
import 'package:ai_gateway_server/src/ai/infrastructure/tools/projects/project_evidence_tool_factory.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

const _projectId = '018f0000-0000-7000-8000-000000000001';
const _tenantId = '018f0000-0000-7000-8000-000000000002';

void main() {
  group('ProjectEvidenceTool', () {
    test(
      'collects only the requested project and forwards bearer token',
      () async {
        final received = <HttpRequest>[];
        final server = await _serve((request) {
          received.add(request);
          return _projectJson();
        });
        addTearDown(() => server.close(force: true));
        final tool = ProjectEvidenceTool(baseUri: _baseUri(server));

        final evidence = await _collect(tool, _request(), 'projects');

        expect(evidence, hasLength(1));
        expect(evidence.single.resourceId, _projectId);
        expect(evidence.single.resourceType, 'project');
        expect(received.single.uri.path, '/projects/$_projectId');
        expect(
          received.single.headers.value(HttpHeaders.authorizationHeader),
          'Bearer access-token',
        );
        expect(
          jsonDecode(evidence.single.summary),
          containsPair('status', 'active'),
        );
      },
    );

    test('rejects a project returned for another tenant', () async {
      final server = await _serve(
        (_) =>
            _projectJson(tenantPartyId: '018f0000-0000-7000-8000-000000000099'),
      );
      addTearDown(() => server.close(force: true));
      final tool = ProjectEvidenceTool(baseUri: _baseUri(server));

      await expectLater(
        _collect(tool, _request(), 'project'),
        throwsA(
          isA<ProjectEvidenceException>().having(
            (error) => error.message,
            'message',
            contains('tenant'),
          ),
        ),
      );
    });

    test('collects bounded recent events for the requested project', () async {
      final paths = <String>[];
      final server = await _serve((request) {
        paths.add(request.uri.path);
        if (request.uri.path.endsWith('/events')) {
          return {
            'items': [
              _eventJson('018f0000-0000-7000-8000-000000000011'),
              _eventJson('018f0000-0000-7000-8000-000000000012'),
            ],
            'count': 2,
          };
        }
        return _projectJson();
      });
      addTearDown(() => server.close(force: true));
      final tool = ProjectEvidenceTool(
        baseUri: _baseUri(server),
        maxRecentEvents: 1,
      );

      final evidence = await _collect(tool, _request(), 'recentEvents');

      expect(paths, ['/projects/$_projectId', '/projects/$_projectId/events']);
      expect(evidence, hasLength(1));
      expect(evidence.single.resourceType, 'projectEvent');
      expect(evidence.single.observedAt, DateTime.utc(2026, 9, 19, 8));
    });

    test('rejects an event returned for another project', () async {
      final server = await _serve((request) {
        if (request.uri.path.endsWith('/events')) {
          return {
            'items': [
              _eventJson(
                '018f0000-0000-7000-8000-000000000011',
                projectId: '018f0000-0000-7000-8000-000000000099',
              ),
            ],
            'count': 1,
          };
        }
        return _projectJson();
      });
      addTearDown(() => server.close(force: true));
      final tool = ProjectEvidenceTool(baseUri: _baseUri(server));

      await expectLater(
        _collect(tool, _request(), 'recentEvents'),
        throwsA(isA<ProjectEvidenceException>()),
      );
    });

    test('fails closed without a bearer token', () async {
      final tool = ProjectEvidenceTool(baseUri: Uri.parse('http://127.0.0.1/'));

      await expectLater(
        _collect(tool, _request(bearerToken: ''), 'project'),
        throwsA(isA<ProjectEvidenceException>()),
      );
    });
  });

  group('ProjectEvidenceToolFactory', () {
    test('returns no tool when Projects is not configured', () {
      expect(ProjectEvidenceToolFactory.fromEnvironment(const {}), isNull);
    });

    test('loads bounded configuration from environment', () {
      final tool = ProjectEvidenceToolFactory.fromEnvironment(const {
        'PROJECTS_BASE_URL': 'http://projects-api:8082',
        'PROJECTS_TIMEOUT_SECONDS': '500',
        'PROJECTS_EVIDENCE_MAX_EVENTS': '0',
        'PROJECTS_EVIDENCE_MAX_BYTES': '99999999',
      });

      expect(tool, isNotNull);
      expect(tool!.baseUri, Uri.parse('http://projects-api:8082/'));
      expect(tool.timeout, const Duration(seconds: 60));
      expect(tool.maxRecentEvents, 1);
      expect(tool.maxResponseBytes, 4 * 1024 * 1024);
    });
  });
}

ReasoningRequest _request({String bearerToken = 'access-token'}) =>
    ReasoningRequest(
      question: 'Quel est le statut du projet ?',
      projectId: UuidValue.withValidation(_projectId),
      tenantPartyId: UuidValue.withValidation(_tenantId),
      bearerToken: bearerToken,
    );

Future<List<EvidenceItem>> _collect(
  ProjectEvidenceTool tool,
  ReasoningRequest request,
  String evidenceType,
) async {
  final result = await tool.execute(
    ToolRequest(evidenceType: evidenceType),
    ToolContext.fromReasoningRequest(request),
  );
  return result.evidence;
}

Map<String, dynamic> _projectJson({String tenantPartyId = _tenantId}) => {
  'id': _projectId,
  'slug': 'nexus',
  'name': 'Nexus',
  'status': 'active',
  'visibility': 'private',
  'tenantPartyId': tenantPartyId,
  'tags': ['backend'],
  'createdAt': '2026-09-18T08:00:00.000Z',
  'updatedAt': '2026-09-19T08:00:00.000Z',
};

Map<String, dynamic> _eventJson(String id, {String projectId = _projectId}) => {
  'id': id,
  'projectId': projectId,
  'kind': 'statusChanged',
  'message': 'Project status changed',
  'occurredAt': '2026-09-19T08:00:00.000Z',
};

Uri _baseUri(HttpServer server) =>
    Uri.parse('http://${server.address.address}:${server.port}/');

Future<HttpServer> _serve(
  Map<String, dynamic> Function(HttpRequest request) response,
) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) {
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(response(request)))
      ..close();
  });
  return server;
}
