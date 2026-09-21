import 'package:identity_server/src/auth/application/services/project_grant_replay_guard.dart';
import 'package:identity_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Project grant anti-replay PostgreSQL proof',
    (sessionBuilder, _) {
      test('one concurrent consumer wins and replay is rejected', () async {
        final firstSession = sessionBuilder.build();
        final secondSession = sessionBuilder.build();
        addTearDown(firstSession.close);
        addTearDown(secondSession.close);
        const jwtId = 'concurrent-grant-proof';
        final expiry = DateTime.now().toUtc().add(const Duration(minutes: 10));
        const guard = ProjectGrantReplayGuard();

        final results = await Future.wait(
          [firstSession, secondSession].map(
            (session) => guard
                .consume(session, jwtId: jwtId, expiresAt: expiry)
                .then<Object?>((_) => null)
                .catchError((Object error) => error),
          ),
        );

        expect(results.where((result) => result == null), hasLength(1));
        expect(results.whereType<FormatException>(), hasLength(1));
        expect(
          await ConsumedProjectAuthorizationGrant.db.count(
            firstSession,
            where: (t) => t.jwtIdHash.equals(
              '6b4521e2a658de7a55b74dee29f3ee7e5aa1e26e82fcd735dc7d67e0b0747d38',
            ),
          ),
          1,
        );
      });
    },
    rollbackDatabase: RollbackDatabase.disabled,
  );
}
