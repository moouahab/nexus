import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

abstract interface class AiRunStore {
  Future<AiRun> insert(Session session, AiRun run);
  Future<AiRun?> findById(Session session, UuidValue id);
  Future<AiRun> update(Session session, AiRun run);
}

final class ServerpodAiRunStore implements AiRunStore {
  const ServerpodAiRunStore();

  @override
  Future<AiRun> insert(Session session, AiRun run) =>
      AiRun.db.insertRow(session, run);

  @override
  Future<AiRun?> findById(Session session, UuidValue id) =>
      AiRun.db.findById(session, id);

  @override
  Future<AiRun> update(Session session, AiRun run) =>
      AiRun.db.updateRow(session, run);
}
