import 'dart:io';

import 'package:ai_gateway_server/src/ai/application/reasoning_artifact_repository.dart';
import 'package:ai_gateway_server/src/ai/application/ai_run_queue.dart';
import 'package:ai_gateway_server/src/ai/domain/reasoning_models.dart';
import 'package:ai_gateway_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  if (Platform.environment['AI_GATEWAY_RUN_DATABASE_TESTS'] != 'true') {
    test(
      'AI reasoning persistence integrity requires the test database',
      () {},
      skip: 'Set AI_GATEWAY_RUN_DATABASE_TESTS=true and start the test stack.',
    );
    return;
  }

  withServerpod('AI reasoning persistence integrity', (sessionBuilder, _) {
    test(
      'persists a claim, its evidence and their association atomically',
      () async {
        final session = sessionBuilder.build();
        addTearDown(session.close);
        final run = await _insertRun(session);

        await const ServerpodReasoningArtifactStore().save(
          session,
          run.id!,
          _outcome(),
        );

        expect(
          await AiClaim.db.count(
            session,
            where: (table) => table.runId.equals(run.id!),
          ),
          1,
        );
        expect(
          await AiEvidence.db.count(
            session,
            where: (table) => table.runId.equals(run.id!),
          ),
          1,
        );
        expect(
          await AiClaimEvidence.db.count(
            session,
            where: (table) => table.runId.equals(run.id!),
          ),
          1,
        );
      },
    );

    test('rejects associations whose claim belongs to another run', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);
      final firstRun = await _insertRun(session);
      final secondRun = await _insertRun(session);
      final claim = await _insertClaim(session, firstRun.id!);
      final evidence = await _insertEvidence(session, secondRun.id!);

      await expectLater(
        AiClaimEvidence.db.insertRow(
          session,
          AiClaimEvidence(
            runId: secondRun.id!,
            claimId: claim.id!,
            evidenceId: evidence.id!,
            relation: 'supports',
          ),
        ),
        throwsA(anything),
      );
    });

    test(
      'rejects associations whose evidence belongs to another run',
      () async {
        final session = sessionBuilder.build();
        addTearDown(session.close);
        final firstRun = await _insertRun(session);
        final secondRun = await _insertRun(session);
        final claim = await _insertClaim(session, firstRun.id!);
        final evidence = await _insertEvidence(session, secondRun.id!);

        await expectLater(
          AiClaimEvidence.db.insertRow(
            session,
            AiClaimEvidence(
              runId: firstRun.id!,
              claimId: claim.id!,
              evidenceId: evidence.id!,
              relation: 'supports',
            ),
          ),
          throwsA(anything),
        );
      },
    );

    test('deleting a run cascades through every reasoning artifact', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);
      final run = await _insertRun(session);
      await const ServerpodReasoningArtifactStore().save(
        session,
        run.id!,
        _outcome(),
      );

      await AiRun.db.deleteRow(session, run);

      expect(await AiClaim.db.count(session), 0);
      expect(await AiEvidence.db.count(session), 0);
      expect(await AiClaimEvidence.db.count(session), 0);
    });

    test('rolls back all writes when artifact persistence fails', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);
      final run = await _insertRun(session);

      await expectLater(
        session.db.transaction((transaction) async {
          await _insertEvidence(session, run.id!, transaction: transaction);
          await _insertClaim(session, run.id!, transaction: transaction);
          throw StateError('simulated persistence failure');
        }),
        throwsStateError,
      );

      expect(
        await AiClaim.db.count(
          session,
          where: (table) => table.runId.equals(run.id!),
        ),
        0,
      );
      expect(
        await AiEvidence.db.count(
          session,
          where: (table) => table.runId.equals(run.id!),
        ),
        0,
      );
    });

    test('cancelling a processing job scrubs its durable payload', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);
      final run = await _insertRun(session);
      final job = await AiRunJob.db.insertRow(
        session,
        AiRunJob(
          runId: run.id!,
          inputJson: '{"prompt":"sensitive"}',
          bearerToken: 'sensitive-token',
          requesterScope: 'service:test',
          tenantPartyId: run.tenantPartyId,
          status: AiRunJobStatus.processing,
          claimedAt: DateTime.now().toUtc(),
        ),
      );

      await const ServerpodAiRunQueue().cancel(session, run.id!);

      final cancelled = await AiRunJob.db.findById(session, job.id!);
      expect(cancelled?.status, AiRunJobStatus.cancelled);
      expect(cancelled?.inputJson, '{}');
      expect(cancelled?.bearerToken, isNull);
    });

    test('worker finalization never overwrites a cancelled job', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);
      final run = await _insertRun(session);
      final job = await AiRunJob.db.insertRow(
        session,
        AiRunJob(
          runId: run.id!,
          inputJson: '{}',
          requesterScope: 'service:test',
          tenantPartyId: run.tenantPartyId,
          status: AiRunJobStatus.cancelled,
          completedAt: DateTime.now().toUtc(),
        ),
      );

      await const AiRunClaimStore().finish(
        session,
        job,
        status: AiRunJobStatus.completed,
      );

      final persisted = await AiRunJob.db.findById(session, job.id!);
      expect(persisted?.status, AiRunJobStatus.cancelled);
    });
  });

  withServerpod(
    'AI run database idempotency',
    (sessionBuilder, _) {
      test('same key and payload returns the original run', () async {
        final session = sessionBuilder.build();
        addTearDown(session.close);
        final tenantId = const Uuid().v7obj();
        const scope = 'identity:idempotency-repeat';
        const key = 'repeat-request';
        final first = await _enqueueRun(
          session,
          tenantId: tenantId,
          requesterScope: scope,
          idempotencyKey: key,
          requestFingerprint: 'fingerprint-a',
        );
        final repeated = await _enqueueRun(
          session,
          tenantId: tenantId,
          requesterScope: scope,
          idempotencyKey: key,
          requestFingerprint: 'fingerprint-a',
        );
        expect(repeated.id, first.id);
        expect(await _jobCount(session, tenantId, scope, key), 1);
        expect(await _futureCallCount(session, first.id!), 1);
      });

      test('same key with a different payload conflicts', () async {
        final session = sessionBuilder.build();
        addTearDown(session.close);
        final tenantId = const Uuid().v7obj();
        const scope = 'identity:idempotency-conflict';
        const key = 'conflicting-request';
        final first = await _enqueueRun(
          session,
          tenantId: tenantId,
          requesterScope: scope,
          idempotencyKey: key,
          requestFingerprint: 'fingerprint-a',
        );
        await expectLater(
          _enqueueRun(
            session,
            tenantId: tenantId,
            requesterScope: scope,
            idempotencyKey: key,
            requestFingerprint: 'fingerprint-b',
          ),
          throwsA(isA<AiRunIdempotencyConflict>()),
        );
        expect(await _jobCount(session, tenantId, scope, key), 1);
        expect(await _futureCallCount(session, first.id!), 1);
      });

      test('concurrent identical requests create one run and job', () async {
        final session = sessionBuilder.build();
        addTearDown(session.close);
        final tenantId = const Uuid().v7obj();
        const scope = 'identity:idempotency-race';
        const key = 'concurrent-request';
        final results = await Future.wait([
          _enqueueRun(
            session,
            tenantId: tenantId,
            requesterScope: scope,
            idempotencyKey: key,
            requestFingerprint: 'fingerprint-a',
          ),
          _enqueueRun(
            session,
            tenantId: tenantId,
            requesterScope: scope,
            idempotencyKey: key,
            requestFingerprint: 'fingerprint-a',
          ),
        ]);
        expect(results[1].id, results[0].id);
        expect(await _jobCount(session, tenantId, scope, key), 1);
        expect(await _futureCallCount(session, results[0].id!), 1);
      });

      test('startup recovery recreates one missing durable call', () async {
        final session = sessionBuilder.build();
        addTearDown(session.close);
        final run = await AiRun.db.insertRow(
          session,
          AiRun(
            requestId: const Uuid().v7obj(),
            projectId: const Uuid().v7obj(),
            tenantPartyId: const Uuid().v7obj(),
            capability: 'project.summary',
            status: AiRunStatus.queued,
          ),
        );
        await AiRunJob.db.insertRow(
          session,
          AiRunJob(
            runId: run.id!,
            inputJson: '{"prompt":"restart-proof"}',
            projectAuthorizationGrant: 'restart-proof-grant',
            requesterScope: 'identity:restart-proof',
            tenantPartyId: run.tenantPartyId,
            status: AiRunJobStatus.queued,
          ),
        );

        expect(await _futureCallCount(session, run.id!), 0);
        expect(await const AiRunClaimStore().recover(session), 1);
        expect(await _futureCallCount(session, run.id!), 1);
        expect(await const AiRunClaimStore().recover(session), 0);
        expect(await _futureCallCount(session, run.id!), 1);
      });
    },
    rollbackDatabase: RollbackDatabase.disabled,
    configOverride: (config) =>
        config.copyWith(futureCallExecutionEnabled: false),
  );
}

Future<AiRun> _enqueueRun(
  Session session, {
  required UuidValue tenantId,
  required String requesterScope,
  required String idempotencyKey,
  required String requestFingerprint,
}) => const ServerpodAiRunQueue().enqueue(
  session,
  run: AiRun(
    requestId: const Uuid().v7obj(),
    projectId: const Uuid().v7obj(),
    tenantPartyId: tenantId,
    capability: 'project.summary',
  ),
  input: const {'prompt': 'Summarize the project.'},
  projectAuthorizationGrant: 'test-project-authorization-grant',
  requesterScope: requesterScope,
  bearerToken: null,
  idempotencyKey: idempotencyKey,
  requestFingerprint: requestFingerprint,
);

Future<int> _jobCount(
  Session session,
  UuidValue tenantId,
  String requesterScope,
  String idempotencyKey,
) => AiRunJob.db.count(
  session,
  where: (table) =>
      table.tenantPartyId.equals(tenantId) &
      table.requesterScope.equals(requesterScope) &
      table.idempotencyKey.equals(idempotencyKey),
);

Future<int> _futureCallCount(Session session, UuidValue runId) =>
    FutureCallEntry.db.count(
      session,
      where: (table) => table.identifier.equals('ai-run:$runId'),
    );

Future<AiRun> _insertRun(Session session) => AiRun.db.insertRow(
  session,
  AiRun(
    requestId: const Uuid().v7obj(),
    projectId: const Uuid().v7obj(),
    tenantPartyId: const Uuid().v7obj(),
    capability: 'project_status',
    status: AiRunStatus.running,
    createdAt: DateTime.now().toUtc(),
  ),
);

Future<AiClaim> _insertClaim(
  Session session,
  UuidValue runId, {
  Transaction? transaction,
}) => AiClaim.db.insertRow(
  session,
  AiClaim(
    runId: runId,
    statement: 'The project is active.',
    claimType: 'fact',
    confidence: 'verified',
    verificationDecision: 'supported',
    iteration: 1,
  ),
  transaction: transaction,
);

Future<AiEvidence> _insertEvidence(
  Session session,
  UuidValue runId, {
  Transaction? transaction,
}) => AiEvidence.db.insertRow(
  session,
  AiEvidence(
    runId: runId,
    sourceService: 'projects',
    resourceType: 'project',
    resourceId: const Uuid().v7(),
    summary: '{"status":"active"}',
    reliability: 0.95,
    freshness: 1,
    collectedAt: DateTime.now().toUtc(),
  ),
  transaction: transaction,
);

ReasoningOutcome _outcome() {
  final now = DateTime.now().toUtc();
  final evidence = EvidenceItem(
    id: 'projects:project:one',
    sourceService: 'projects',
    resourceType: 'project',
    resourceId: 'one',
    summary: '{"status":"active"}',
    collectedAt: now,
    observedAt: now,
    reliability: 95,
    projectId: UuidValue.withValidation('018f0000-0000-7000-8000-000000000001'),
    tenantPartyId: UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000002',
    ),
  );
  final claim = ClaimCandidate(
    id: 'claim-one',
    statement: 'The project is active.',
    type: ClaimType.fact,
    evidenceRelations: {evidence.id: EvidenceRelation.supports},
  );
  return ReasoningOutcome(
    answer: 'Le projet est actif.',
    level: ReasoningLevel.standard,
    iterations: 1,
    claims: [
      ClaimVerification(
        claim: claim,
        decision: VerificationDecision.supported,
        confidence: EvidenceConfidence.verified,
        score: 95,
        supportingEvidenceIds: [evidence.id],
        contradictingEvidenceIds: const [],
      ),
    ],
    evidence: [evidence],
    validated: true,
    finalDecision: CritiqueDecision.accept,
  );
}
