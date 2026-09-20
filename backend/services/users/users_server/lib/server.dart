import 'package:serverpod/serverpod.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/users/http/user_http_routes.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: (_, _) async => null,
  );

  registerUserHttpRoutes(pod);
  await pod.start();
}
