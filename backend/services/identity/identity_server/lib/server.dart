import 'package:serverpod/serverpod.dart';
import 'package:nexus_auth/nexus_auth.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/auth/routes/register_auth_routes.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  await NexusTelemetry.initialize('identity');
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: (session, token) async => null,
  );

  registerAuthRoutes(pod);
  // Start the server.
  await pod.start();
}
