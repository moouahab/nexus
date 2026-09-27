import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart';

import '../../generated/protocol.dart';

abstract interface class AiRunQueue {
  Future<AiRun> enqueue(
    Session session, {
    required AiRun run,
    required Map<String, dynamic> input,
    required String projectAuthorizationGrant,
    required String requesterScope,
    required String? bearerToken,
    required String? idempotencyKey,
    required String? requestFingerprint,
  });

  Future<void> cancel(Session session, UuidValue runId);
}

final class ServerpodAiRunQueue implements AiRunQueue {
  const ServerpodAiRunQueue();

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
    if (idempotencyKey != null) {
      final existingJob = await AiRunJob.db.findFirstRow(
        session,
        where: (t) =>
            t.tenantPartyId.equals(run.tenantPartyId) &
            t.requesterScope.equals(requesterScope) &
            t.idempotencyKey.equals(idempotencyKey),
      );
      if (existingJob != null) {
        _requireMatchingFingerprint(existingJob, requestFingerprint);
        return (await AiRun.db.findById(session, existingJob.runId))!;
      }
    }

    try {
      return await session.db.transaction((transaction) async {
        final inserted = await AiRun.db.insertRow(
          session,
          run,
          transaction: transaction,
        );
        await AiRunJob.db.insertRow(
          session,
          AiRunJob(
            runId: inserted.id!,
            inputJson: jsonEncode(input),
            projectAuthorizationGrant: projectAuthorizationGrant,
            bearerToken: bearerToken,
            idempotencyKey: idempotencyKey,
            requestFingerprint: requestFingerprint,
            requesterScope: requesterScope,
            tenantPartyId: run.tenantPartyId,
          ),
          transaction: transaction,
        );
        final work = AiRunWork(runId: inserted.id!);
        await FutureCallEntry.db.insertRow(
          session,
          FutureCallEntry(
            name: 'AiRunExecuteFutureCall',
            time: DateTime.now().toUtc(),
            serializedObject: SerializationManager.encode(work.toJson()),
            serverId: session.serverpod.serverId,
            identifier: 'ai-run:${inserted.id}',
          ),
          transaction: transaction,
        );
        return inserted;
      });
    } on DatabaseQueryException catch (error) {
      if (idempotencyKey == null ||
          error.code != '23505' ||
          error.constraintName != 'ai_run_job_idempotency_idx') {
        rethrow;
      }
      final winner = await AiRunJob.db.findFirstRow(
        session,
        where: (t) =>
            t.tenantPartyId.equals(run.tenantPartyId) &
            t.requesterScope.equals(requesterScope) &
            t.idempotencyKey.equals(idempotencyKey),
      );
      if (winner == null) rethrow;
      _requireMatchingFingerprint(winner, requestFingerprint);
      return (await AiRun.db.findById(session, winner.runId))!;
    }
  }

  void _requireMatchingFingerprint(
    AiRunJob existing,
    String? requestFingerprint,
  ) {
    if (existing.requestFingerprint != requestFingerprint) {
      throw const AiRunIdempotencyConflict();
    }
  }

  @override
  Future<void> cancel(Session session, UuidValue runId) async {
    await FutureCallEntry.db.deleteWhere(
      session,
      where: (t) => t.identifier.equals('ai-run:$runId'),
    );
    final now = DateTime.now().toUtc();
    await AiRunJob.db.updateWhere(
      session,
      columnValues: (t) => [
        t.status(AiRunJobStatus.cancelled),
        t.inputJson('{}'),
        t.projectAuthorizationGrant(null),
        t.bearerToken(null),
        t.completedAt(now),
        t.updatedAt(now),
      ],
      where: (t) =>
          t.runId.equals(runId) &
          (t.status.equals(AiRunJobStatus.queued) |
              t.status.equals(AiRunJobStatus.processing)),
    );
  }
}

/// A stable idempotency key was reused for a semantically different request.
final class AiRunIdempotencyConflict implements Exception {
  const AiRunIdempotencyConflict();

  @override
  String toString() => 'Idempotency key conflicts with the original request.';
}

final class ClaimedAiRunJob {
  const ClaimedAiRunJob(this.run, this.job);
  final AiRun run;
  final AiRunJob job;
}

final class AiRunClaimStore {
  const AiRunClaimStore();

  /// Repairs the narrow crash window after Serverpod dequeues a FutureCall
  /// and before this worker claims its durable job. A processing lease is
  /// also returned to the queue after a conservative timeout.
  Future<int> recover(
    Session session, {
    Duration processingLease = const Duration(minutes: 30),
    int limit = 1000,
  }) async {
    final staleBefore = DateTime.now().toUtc().subtract(processingLease);
    final jobs = await AiRunJob.db.find(
      session,
      where: (t) =>
          t.status.equals(AiRunJobStatus.queued) |
          (t.status.equals(AiRunJobStatus.processing) &
              (t.claimedAt < staleBefore)),
      limit: limit,
      orderBy: (t) => t.createdAt,
    );
    var recovered = 0;
    for (final candidate in jobs) {
      await session.db.transaction((transaction) async {
        final job = await AiRunJob.db.findById(
          session,
          candidate.id!,
          transaction: transaction,
          lockMode: LockMode.forUpdate,
        );
        if (job == null ||
            (job.status != AiRunJobStatus.queued &&
                !(job.status == AiRunJobStatus.processing &&
                    job.claimedAt != null &&
                    job.claimedAt!.isBefore(staleBefore)))) {
          return;
        }
        final identifier = 'ai-run:${job.runId}';
        final existing = await FutureCallEntry.db.findFirstRow(
          session,
          where: (t) => t.identifier.equals(identifier),
          transaction: transaction,
        );
        if (existing != null) return;
        final now = DateTime.now().toUtc();
        if (job.status == AiRunJobStatus.processing) {
          await AiRunJob.db.updateRow(
            session,
            job.copyWith(
              status: AiRunJobStatus.queued,
              claimedAt: null,
              updatedAt: now,
            ),
            transaction: transaction,
          );
          final run = await AiRun.db.findById(
            session,
            job.runId,
            transaction: transaction,
            lockMode: LockMode.forUpdate,
          );
          if (run != null) {
            await AiRun.db.updateRow(
              session,
              run.copyWith(status: AiRunStatus.queued, updatedAt: now),
              transaction: transaction,
            );
          }
        }
        final work = AiRunWork(runId: job.runId);
        await FutureCallEntry.db.insertRow(
          session,
          FutureCallEntry(
            name: 'AiRunExecuteFutureCall',
            time: now,
            serializedObject: SerializationManager.encode(work.toJson()),
            serverId: session.serverpod.serverId,
            identifier: identifier,
          ),
          transaction: transaction,
        );
        recovered++;
      });
    }
    return recovered;
  }

  /// Atomically transitions queued -> processing. Duplicate worker messages
  /// therefore become harmless no-ops.
  Future<ClaimedAiRunJob?> claim(Session session, UuidValue runId) {
    return session.db.transaction((transaction) async {
      final job = await AiRunJob.db.findFirstRow(
        session,
        where: (t) => t.runId.equals(runId),
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (job == null || job.status != AiRunJobStatus.queued) return null;
      final run = await AiRun.db.findById(
        session,
        runId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (run == null || run.status != AiRunStatus.queued) return null;
      final now = DateTime.now().toUtc();
      final claimedJob = await AiRunJob.db.updateRow(
        session,
        job.copyWith(
          status: AiRunJobStatus.processing,
          attemptCount: job.attemptCount + 1,
          claimedAt: now,
          updatedAt: now,
        ),
        transaction: transaction,
      );
      final claimedRun = await AiRun.db.updateRow(
        session,
        run.copyWith(status: AiRunStatus.running, updatedAt: now),
        transaction: transaction,
      );
      return ClaimedAiRunJob(claimedRun, claimedJob);
    });
  }

  Future<void> finish(
    Session session,
    AiRunJob job, {
    required AiRunJobStatus status,
    String? errorCode,
  }) async {
    await session.db.transaction((transaction) async {
      final current = await AiRunJob.db.findById(
        session,
        job.id!,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (current == null || current.status == AiRunJobStatus.cancelled) return;
      final now = DateTime.now().toUtc();
      await AiRunJob.db.updateRow(
        session,
        current.copyWith(
          inputJson: '{}',
          projectAuthorizationGrant: null,
          bearerToken: null,
          status: status,
          completedAt: now,
          lastErrorCode: errorCode,
          updatedAt: now,
        ),
        transaction: transaction,
      );
    });
  }
}
