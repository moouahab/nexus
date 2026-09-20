import 'package:serverpod/serverpod.dart';
import 'package:nexus_auth/nexus_auth.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/projects/http/project_http_routes.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  await NexusTelemetry.initialize('projects');
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: (_, _) async => null,
  );

  registerProjectHttpRoutes(pod);

  // Start the server.
  await pod.start();
}
