import 'package:ai_gateway_server/src/ai/application/ai_provider.dart';
import 'package:ai_gateway_server/src/ai/application/ai_run_repository.dart';
import 'package:ai_gateway_server/src/ai/application/ai_run_queue.dart';
import 'package:ai_gateway_server/src/ai/application/ai_run_service.dart';
import 'package:ai_gateway_server/src/ai/application/project_authorization.dart';
import 'package:ai_gateway_server/src/generated/protocol.dart';
import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  final runId = _uuid('018f0000-0000-7000-8000-000000000001');
  final projectId = _uuid('018f0000-0000-7000-8000-000000000002');
  final tenantId = _uuid('018f0000-0000-7000-8000-000000000003');
  final ownerId = _uuid('018f0000-0000-7000-8000-000000000004');
  final attackerId = _uuid('018f0000-0000-7000-8000-000000000005');

  AiRun run({AiRunStatus status = AiRunStatus.running}) => AiRun(
    id: runId,
    requestId: _uuid('018f0000-0000-7000-8000-000000000006'),
    projectId: projectId,
    tenantPartyId: tenantId,
    capability: 'summary',
    status: status,
    requesterIdentityId: ownerId,
    createdAt: DateTime.utc(2026),
  );

  test('get fails closed when the Projects adapter is unavailable', () async {
    final service = AiRunService(repository: _MemoryRunStore(run()));

    await expectLater(
      service.get(_UnusedSession(), runId, requesterIdentityId: ownerId),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'get rejects horizontal access and checks run project and tenant',
    () async {
      final authorization = _RecordingAuthorization(allowedIdentityId: ownerId);
      final service = AiRunService(
        authorization: authorization,
        repository: _MemoryRunStore(run()),
      );

      await expectLater(
        service.get(_UnusedSession(), runId, requesterIdentityId: attackerId),
        throwsA(_concealedRunNotFound),
      );

      await expectLater(
        service.get(
          _UnusedSession(),
          _uuid('018f0000-0000-7000-8000-000000009999'),
          requesterIdentityId: attackerId,
        ),
        throwsA(_concealedRunNotFound),
      );

      expect(authorization.projectId, projectId);
      expect(authorization.tenantPartyId, tenantId);
      expect(authorization.identityId, attackerId);
    },
  );

  test('cancel does not update a run when project access is denied', () async {
    final repository = _MemoryRunStore(run());
    final service = AiRunService(
      authorization: _RecordingAuthorization(allowedIdentityId: ownerId),
      repository: repository,
      queue: _MemoryQueue(),
    );

    await expectLater(
      service.cancel(_UnusedSession(), runId, requesterIdentityId: attackerId),
      throwsA(isA<StateError>()),
    );

    expect(repository.updateCount, 0);
    expect(repository.run.status, AiRunStatus.running);
  });

  test('service token cannot read an AI run outside its project', () async {
    final service = AiRunService(
      authorization: _RecordingAuthorization(allowedIdentityId: ownerId),
      repository: _MemoryRunStore(run()),
    );
    final context = ServiceAuthContext(
      serviceName: 'projects',
      issuer: AuthTokenDefaults.issuer,
      audiences: const ['ai-gateway'],
      scopes: const ['ai.run.read'],
      issuedAt: DateTime.utc(2026),
      expiresAt: DateTime.utc(2099),
      projectId: '018f0000-0000-7000-8000-000000000099',
    );

    await expectLater(
      service.get(
        _UnusedSession(),
        runId,
        requesterService: 'projects',
        serviceContext: context,
      ),
      throwsA(_concealedRunNotFound),
    );
  });

  test('authorized caller can read and cancel its project run', () async {
    final repository = _MemoryRunStore(run());
    final service = AiRunService(
      authorization: _RecordingAuthorization(allowedIdentityId: ownerId),
      repository: repository,
      queue: _MemoryQueue(),
    );

    final fetched = await service.get(
      _UnusedSession(),
      runId,
      requesterIdentityId: ownerId,
    );
    final cancelled = await service.cancel(
      _UnusedSession(),
      runId,
      requesterIdentityId: ownerId,
    );

    expect(fetched.id, runId);
    expect(cancelled.status, AiRunStatus.cancelled);
    expect(repository.updateCount, 1);
  });

  test('authorized create enqueues without executing the provider', () async {
    final repository = _MemoryRunStore(run(status: AiRunStatus.queued));
    final provider = _FakeProvider();
    final queue = _MemoryQueue();
    final service = AiRunService(
      authorization: _RecordingAuthorization(allowedIdentityId: ownerId),
      repository: repository,
      provider: provider,
      queue: queue,
    );

    final created = await service.create(
      _UnusedSession(),
      projectId: projectId,
      tenantPartyId: tenantId,
      capability: 'project.summary',
      input: const {'prompt': 'Summarize the authorized project.'},
      requesterIdentityId: ownerId,
      bearerToken: 'inbound-user-token-must-not-be-persisted',
      idempotencyKey: ' stable-request ',
    );

    expect(created.status, AiRunStatus.queued);
    expect(created.provider, 'fake');
    expect(created.model, 'test-model');
    expect(created.outputText, isNull);
    expect(repository.updateCount, 0);
    expect(provider.generateCount, 0);
    expect(queue.requesterScope, 'identity:$ownerId');
    expect(queue.bearerToken, isNull);
    expect(queue.input!.containsKey('_projectAuthorizationGrant'), isFalse);
    expect(queue.projectAuthorizationGrant, 'signed-project-grant');
    expect(queue.idempotencyKey, 'stable-request');
  });

  test(
    'service token run creation fails closed without user delegation',
    () async {
      final queue = _MemoryQueue();
      final service = AiRunService(
        authorization: _RecordingAuthorization(allowedIdentityId: ownerId),
        repository: _MemoryRunStore(run()),
        provider: _FakeProvider(),
        queue: queue,
      );
      final context = ServiceAuthContext(
        serviceName: 'automation',
        issuer: AuthTokenDefaults.issuer,
        audiences: const ['ai-gateway'],
        scopes: const ['ai.run.create'],
        issuedAt: DateTime.utc(2026),
        expiresAt: DateTime.utc(2099),
        projectId: projectId.toString(),
      );

      await expectLater(
        service.create(
          _UnusedSession(),
          projectId: projectId,
          tenantPartyId: tenantId,
          capability: 'project.summary',
          input: const {'prompt': 'Summarize.'},
          requesterService: 'automation',
          serviceContext: context,
        ),
        throwsA(isA<StateError>()),
      );
      expect(queue.enqueueCount, 0);
    },
  );

  test('idempotency key is bounded before enqueue', () async {
    final queue = _MemoryQueue();
    final service = AiRunService(
      authorization: _RecordingAuthorization(allowedIdentityId: ownerId),
      repository: _MemoryRunStore(run()),
      provider: _FakeProvider(),
      queue: queue,
    );
    await expectLater(
      service.create(
        _UnusedSession(),
        projectId: projectId,
        tenantPartyId: tenantId,
        capability: 'project.summary',
        input: const {'prompt': 'Summarize.'},
        requesterIdentityId: ownerId,
        idempotencyKey: 'x' * 129,
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(queue.enqueueCount, 0);
  });
}

final _concealedRunNotFound = isA<StateError>().having(
  (error) => error.message,
  'message',
  'AI run not found.',
);

UuidValue _uuid(String value) => UuidValue.withValidation(value);

final class _RecordingAuthorization implements ProjectAuthorization {
  _RecordingAuthorization({required this.allowedIdentityId});

  final UuidValue allowedIdentityId;
  UuidValue? projectId;
  UuidValue? tenantPartyId;
  UuidValue? identityId;

  @override
  Future<String?> authorizeProject({
    required UuidValue projectId,
    required UuidValue tenantPartyId,
    UuidValue? identityId,
    String? serviceName,
    String? bearerToken,
  }) async {
    this.projectId = projectId;
    this.tenantPartyId = tenantPartyId;
    this.identityId = identityId;
    return identityId == allowedIdentityId ? 'signed-project-grant' : null;
  }
}

final class _MemoryRunStore implements AiRunStore {
  _MemoryRunStore(this.run);

  AiRun run;
  int updateCount = 0;

  @override
  Future<AiRun?> findById(Session session, UuidValue id) async =>
      id == run.id ? run : null;

  @override
  Future<AiRun> insert(Session session, AiRun run) async => this.run = run;

  @override
  Future<AiRun> update(Session session, AiRun run) async {
    updateCount++;
    return this.run = run;
  }
}

final class _UnusedSession implements Session {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeProvider implements AiProvider {
  int generateCount = 0;

  @override
  bool get isConfigured => true;

  @override
  String get model => 'test-model';

  @override
  String get name => 'fake';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<AiGenerationResult> generate(AiGenerationRequest request) async {
    generateCount++;
    return const AiGenerationResult(
      provider: 'fake',
      model: 'test-model',
      output: 'Generated result',
    );
  }
}

final class _MemoryQueue implements AiRunQueue {
  int enqueueCount = 0;
  String? requesterScope;
  String? bearerToken;
  String? idempotencyKey;
  String? requestFingerprint;
  Map<String, dynamic>? input;
  String? projectAuthorizationGrant;

  @override
  Future<AiRun> enqueue(
    Session session, {
    required AiRun run,
    required Map<String, dynamic> input,
    required String projectAuthorizationGrant,
    required String requesterScope,
    required String? bearerToken,
    required String? idempotencyKey,
    required String? requestFingerprint,
  }) async {
    enqueueCount++;
    this.input = input;
    this.projectAuthorizationGrant = projectAuthorizationGrant;
    this.requesterScope = requesterScope;
    this.bearerToken = bearerToken;
    this.idempotencyKey = idempotencyKey;
    this.requestFingerprint = requestFingerprint;
    return run.copyWith(id: _uuid('018f0000-0000-7000-8000-000000000009'));
  }

  @override
  Future<void> cancel(Session session, UuidValue runId) async {}
}
