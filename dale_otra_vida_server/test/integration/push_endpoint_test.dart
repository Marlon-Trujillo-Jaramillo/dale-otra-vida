import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'package:dale_otra_vida_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Push endpoint', (sessionBuilder, endpoints) {
    Future<(TestSessionBuilder, MemberProfile)> member(String name) async {
      final authUser = await AuthUser.db.insertRow(
        sessionBuilder.build(),
        AuthUser(scopeNames: {}),
      );
      final session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUser.id!.uuid,
          {},
        ),
      );
      final profile = await endpoints.profile.saveMe(
        session,
        displayName: name,
      );
      return (session, profile);
    }

    test(
      'register stores the token once and moves it between accounts',
      () async {
        final (ana, anaProfile) = await member('Ana');
        final (luis, luisProfile) = await member('Luis');

        await endpoints.push.register(ana, 'token-1', 'web');
        await endpoints.push.register(ana, 'token-1', 'web');
        var rows = await PushToken.db.find(sessionBuilder.build());
        expect(rows.single.profileId, anaProfile.id);

        await endpoints.push.register(luis, 'token-1', 'android');
        rows = await PushToken.db.find(sessionBuilder.build());
        expect(rows.single.profileId, luisProfile.id);
        expect(rows.single.platform, 'android');
      },
    );

    test('rejects unknown platforms and empty tokens', () async {
      final (ana, _) = await member('Ana');
      final denied = throwsA(isA<NotAllowedException>());
      await expectLater(endpoints.push.register(ana, 'token', 'tv'), denied);
      await expectLater(endpoints.push.register(ana, '  ', 'web'), denied);
    });

    test('unregister only removes the caller\'s token', () async {
      final (ana, _) = await member('Ana');
      final (luis, _) = await member('Luis');
      await endpoints.push.register(ana, 'token-ana', 'web');

      await endpoints.push.unregister(luis, 'token-ana');
      expect(await PushToken.db.count(sessionBuilder.build()), 1);

      await endpoints.push.unregister(ana, 'token-ana');
      expect(await PushToken.db.count(sessionBuilder.build()), 0);
    });

    test('is disabled without a Firebase service account', () async {
      final (ana, _) = await member('Ana');
      expect(await endpoints.push.enabled(ana), isFalse);
    });
  });
}
