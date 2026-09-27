import 'package:serverpod/serverpod.dart';
import 'package:nexus_auth/nexus_auth.dart';
// ignore: implementation_imports
import 'package:serverpod/src/server/serverpod.dart'
    show ServerpodInternalMethods;

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/ai/http/ai_http_routes.dart';
import 'src/ai/application/ai_run_queue.dart';

Future<void> run(List<String> args) async {
  await NexusTelemetry.initialize('ai-gateway');
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: (_, _) async => null,
  );
  registerAiHttpRoutes(pod);
  await pod.start();
  final recovered = await const AiRunClaimStore().recover(pod.internalSession);
  if (recovered > 0) {
    pod.internalSession.log('Recovered $recovered durable AI run job(s).');
  }
}
