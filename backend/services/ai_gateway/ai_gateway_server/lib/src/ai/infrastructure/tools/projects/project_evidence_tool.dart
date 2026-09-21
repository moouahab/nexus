import 'dart:convert';
import 'dart:io';

import 'package:nexus_auth/nexus_auth.dart';
import '../../../application/tools/nexus_tool.dart';
import '../../../domain/reasoning_models.dart';

final class ProjectEvidenceException implements Exception {
  const ProjectEvidenceException(this.message);

  final String message;

  @override
  String toString() => 'ProjectEvidenceException: $message';
}

/// Collects evidence from the Projects REST facade.
///
/// Every collection is scoped to the project and tenant carried by the
/// [ReasoningRequest]. The bearer token is a short-lived `projects-service`
/// token created by Identity for this exact tenant/project boundary. The
/// original inbound `ai-gateway` bearer is never forwarded.
final class ProjectEvidenceTool implements NexusTool {
  ProjectEvidenceTool({
    required Uri baseUri,
    this.timeout = const Duration(seconds: 10),
    this.maxRecentEvents = 25,
    this.maxResponseBytes = 1024 * 1024,
    HttpClient? client,
  }) : baseUri = _validateBaseUri(baseUri),
       _client = client ?? HttpClient() {
    if (maxRecentEvents < 1 || maxRecentEvents > 100) {
      throw ArgumentError.value(
        maxRecentEvents,
        'maxRecentEvents',
        'Expected a value between 1 and 100.',
      );
    }
    if (maxResponseBytes < 1024) {
      throw ArgumentError.value(
        maxResponseBytes,
        'maxResponseBytes',
        'Expected at least 1024 bytes.',
      );
    }
  }

  final Uri baseUri;
  final Duration timeout;
  final int maxRecentEvents;
  final int maxResponseBytes;
  final HttpClient _client;

  @override
  String get name => 'projects';

  @override
  Set<String> get supportedEvidenceTypes => const {
    'project',
    'projects',
    'recentEvents',
    'project.status',
    'project.events',
  };

  @override
  Future<ToolResult> execute(ToolRequest request, ToolContext context) async {
    if (!supportedEvidenceTypes.contains(request.evidenceType)) {
      return const ToolResult.unsupported();
    }
    if (context.bearerToken.trim().isEmpty) {
      throw const ProjectEvidenceException('A bearer token is required.');
    }

    // Fetching the project first both authorizes the caller in Projects and
    // lets the Gateway independently enforce tenant/project isolation.
    final project = await _getObject(
      baseUri.resolve('projects/${context.projectId}'),
      context.bearerToken,
    );
    _requireProjectScope(project, context);

    if (const {
      'recentEvents',
      'project.events',
    }.contains(request.evidenceType)) {
      return ToolResult.success(await _collectRecentEvents(context));
    }
    return ToolResult.success([_projectEvidence(project, context)]);
  }

  Future<List<EvidenceItem>> _collectRecentEvents(ToolContext context) async {
    final response = await _getObject(
      baseUri.resolve('projects/${context.projectId}/events'),
      context.bearerToken,
    );
    final rawItems = response['items'];
    if (rawItems is! List) {
      throw const ProjectEvidenceException(
        'Projects returned an invalid events response.',
      );
    }

    final evidence = <EvidenceItem>[];
    for (final raw in rawItems.take(maxRecentEvents)) {
      if (raw is! Map) {
        throw const ProjectEvidenceException(
          'Projects returned an invalid event.',
        );
      }
      final event = Map<String, dynamic>.from(raw);
      if (event['projectId'] != context.projectId.toString()) {
        throw const ProjectEvidenceException(
          'Projects returned an event outside the requested project.',
        );
      }
      final eventId = _requiredString(event, 'id');
      final occurredAt = _dateTime(event['occurredAt']);
      evidence.add(
        EvidenceItem(
          id: 'projects:event:$eventId',
          sourceService: name,
          resourceType: 'projectEvent',
          resourceId: eventId,
          summary: jsonEncode({
            'kind': event['kind'],
            if (event['message'] != null) 'message': event['message'],
            if (event['resourceKind'] != null)
              'resourceKind': event['resourceKind'],
            if (event['resourceService'] != null)
              'resourceService': event['resourceService'],
            if (event['resourceExternalId'] != null)
              'resourceExternalId': event['resourceExternalId'],
            'occurredAt': event['occurredAt'],
          }),
          observedAt: occurredAt,
          collectedAt: DateTime.now().toUtc(),
          reliability: 90,
          projectId: context.projectId,
          tenantPartyId: context.tenantPartyId,
          freshness: EvidenceFreshness.current,
          data: Map.unmodifiable(event),
        ),
      );
    }
    return evidence;
  }

  EvidenceItem _projectEvidence(
    Map<String, dynamic> project,
    ToolContext context,
  ) {
    final projectId = _requiredString(project, 'id');
    return EvidenceItem(
      id: 'projects:project:$projectId',
      sourceService: name,
      resourceType: 'project',
      resourceId: projectId,
      summary: jsonEncode({
        'name': project['name'],
        'slug': project['slug'],
        if (project['summary'] != null) 'summary': project['summary'],
        'status': project['status'],
        'visibility': project['visibility'],
        'tenantPartyId': project['tenantPartyId'],
        'tags': project['tags'] ?? const <Object>[],
        'createdAt': project['createdAt'],
        if (project['updatedAt'] != null) 'updatedAt': project['updatedAt'],
        if (project['archivedAt'] != null) 'archivedAt': project['archivedAt'],
      }),
      observedAt: _dateTime(project['updatedAt'] ?? project['createdAt']),
      collectedAt: DateTime.now().toUtc(),
      reliability: 95,
      projectId: context.projectId,
      tenantPartyId: context.tenantPartyId,
      freshness: EvidenceFreshness.current,
      data: Map.unmodifiable(project),
    );
  }

  void _requireProjectScope(Map<String, dynamic> project, ToolContext context) {
    if (project['id'] != context.projectId.toString()) {
      throw const ProjectEvidenceException(
        'Projects returned a different project.',
      );
    }
    if (project['tenantPartyId'] != context.tenantPartyId.toString()) {
      throw const ProjectEvidenceException(
        'The project does not belong to the requested tenant.',
      );
    }
  }

  Future<Map<String, dynamic>> _getObject(Uri uri, String bearerToken) async {
    try {
      final request = await _client.getUrl(uri).timeout(timeout);
      request.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer $bearerToken')
        ..set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
      NexusObservability.addOutboundHeaders(request.headers);
      final response = await request.close().timeout(timeout);
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>().timeout(timeout);
        throw ProjectEvidenceException(
          'Projects request failed with status ${response.statusCode}.',
        );
      }
      if (response.contentLength > maxResponseBytes) {
        throw const ProjectEvidenceException(
          'Projects response exceeds the configured size limit.',
        );
      }
      final bytes = <int>[];
      await for (final chunk in response.timeout(timeout)) {
        bytes.addAll(chunk);
        if (bytes.length > maxResponseBytes) {
          throw const ProjectEvidenceException(
            'Projects response exceeds the configured size limit.',
          );
        }
      }
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) {
        throw const ProjectEvidenceException(
          'Projects returned an invalid JSON object.',
        );
      }
      return Map<String, dynamic>.from(decoded);
    } on ProjectEvidenceException {
      rethrow;
    } on Object catch (error) {
      throw ProjectEvidenceException('Projects request failed: $error');
    }
  }

  static String _requiredString(Map<String, dynamic> value, String field) {
    final result = value[field];
    if (result is! String || result.isEmpty) {
      throw ProjectEvidenceException('Projects response is missing "$field".');
    }
    return result;
  }

  static DateTime? _dateTime(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toUtc() : null;

  static Uri _validateBaseUri(Uri uri) {
    if (!{'http', 'https'}.contains(uri.scheme) || uri.host.isEmpty) {
      throw ArgumentError.value(uri, 'baseUri', 'Expected an HTTP(S) URI.');
    }
    return uri.path.endsWith('/') ? uri : uri.replace(path: '${uri.path}/');
  }
}
