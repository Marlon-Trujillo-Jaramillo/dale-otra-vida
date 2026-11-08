import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'package:dale_otra_vida_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given an email that already signs in with Google', (
    sessionBuilder,
    endpoints,
  ) {
    setUp(() async {
      final authUser = await AuthUser.db.insertRow(
        sessionBuilder.build(),
        AuthUser(scopeNames: {}),
      );
      await GoogleAccount.db.insertRow(
        sessionBuilder.build(),
        GoogleAccount(
          userIdentifier: 'google-123',
          email: 'ana@gmail.com',
          authUserId: authUser.id!,
        ),
      );
    });

    test(
      'email sign-up points to Google instead of a second account',
      () async {
        await expectLater(
          endpoints.emailIdp.startRegistration(
            sessionBuilder,
            email: ' Ana@Gmail.com ',
          ),
          throwsA(isA<NotAllowedException>()),
        );
      },
    );
  });
}
