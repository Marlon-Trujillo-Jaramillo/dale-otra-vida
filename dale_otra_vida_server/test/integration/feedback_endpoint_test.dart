import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'package:dale_otra_vida_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Feedback endpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder member;
    late MemberProfile profile;

    setUp(() async {
      final authUser = await AuthUser.db.insertRow(
        sessionBuilder.build(),
        AuthUser(scopeNames: {}),
      );
      member = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUser.id!.uuid,
          {},
        ),
      );
      profile = await endpoints.profile.saveMe(member, displayName: 'Ana');
    });

    test('stores a trimmed opinion with its context', () async {
      await endpoints.feedback.send(
        member,
        '  El chat me gustó mucho  ',
        rating: 5,
        screen: 'chat',
        platform: 'web',
      );
      final rows = await AppFeedback.db.find(sessionBuilder.build());
      expect(rows.single.message, 'El chat me gustó mucho');
      expect(rows.single.rating, 5);
      expect(rows.single.screen, 'chat');
      expect(rows.single.profileId, profile.id);
    });

    test('rejects empty, too long and out-of-range opinions', () async {
      final denied = throwsA(isA<NotAllowedException>());
      await expectLater(endpoints.feedback.send(member, ' a '), denied);
      await expectLater(endpoints.feedback.send(member, 'x' * 1001), denied);
      await expectLater(
        endpoints.feedback.send(member, 'Muy bien', rating: 6),
        denied,
      );
    });

    test('limits opinions per day', () async {
      for (var i = 0; i < 20; i++) {
        await endpoints.feedback.send(member, 'Comentario $i');
      }
      await expectLater(
        endpoints.feedback.send(member, 'Uno más'),
        throwsA(isA<NotAllowedException>()),
      );
    });
  });
}
