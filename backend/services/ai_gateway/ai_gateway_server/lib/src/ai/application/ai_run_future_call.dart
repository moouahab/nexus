import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../infrastructure/ai_provider_factory.dart';
import '../infrastructure/reasoning_orchestrator_factory.dart';
import 'ai_run_processor.dart';

/// Persistent, restart-safe worker entry point managed by Serverpod.
final class AiRunFutureCall extends FutureCall {
  Future<void> execute(Session session, AiRunWork work) async {
    final provider = AiProviderFactory.fromEnvironment();
    final processor = AiRunProcessor(
      provider: provider,
      orchestrator: provider.isConfigured
          ? ReasoningOrchestratorFactory.fromEnvironment(provider)
          : null,
    );
    await processor.process(session, work.runId);
  }
}
