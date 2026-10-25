import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'package:dale_otra_vida_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Notification endpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder memberA;
    late TestSessionBuilder memberB;
    late MemberProfile profileA;
    late MemberProfile profileB;

    setUp(() async {
      final authUserA = await AuthUser.db.insertRow(
        sessionBuilder.build(),
        AuthUser(scopeNames: {}),
      );
      memberA = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUserA.id!.uuid,
          {},
        ),
      );
      profileA = await endpoints.profile.saveMe(memberA, displayName: 'Ana');

      final authUserB = await AuthUser.db.insertRow(
        sessionBuilder.build(),
        AuthUser(scopeNames: {}),
      );
      memberB = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUserB.id!.uuid,
          {},
        ),
      );
      profileB = await endpoints.profile.saveMe(memberB, displayName: 'Luis');
    });

    Future<AppNotification> insertNotification(
      int userId,
      String title, {
      DateTime? createdAt,
      DateTime? readAt,
    }) {
      return AppNotification.db.insertRow(
        sessionBuilder.build(),
        AppNotification(
          userId: userId,
          kind: NotificationKind.newMessage,
          title: title,
          body: 'Cuerpo de $title',
          readAt: readAt,
          createdAt: createdAt ?? DateTime.now().toUtc(),
        ),
      );
    }

    group('when listing notifications', () {
      test(
        'returns only the notifications of the caller, newest first',
        () async {
          final now = DateTime.now().toUtc();
          await insertNotification(
            profileA.id!,
            'Vieja',
            createdAt: now.subtract(const Duration(hours: 2)),
          );
          await insertNotification(
            profileA.id!,
            'Media',
            createdAt: now.subtract(const Duration(hours: 1)),
          );
          await insertNotification(profileA.id!, 'Nueva');
          await insertNotification(profileB.id!, 'Ajena');

          final list = await endpoints.notification.list(
            memberA,
            limit: 30,
            offset: 0,
          );

          expect(list.map((n) => n.title), ['Nueva', 'Media', 'Vieja']);
        },
      );

      test('clamps the limit and applies the offset', () async {
        final now = DateTime.now().toUtc();
        await insertNotification(
          profileA.id!,
          'Uno',
          createdAt: now.subtract(const Duration(hours: 3)),
        );
        await insertNotification(
          profileA.id!,
          'Dos',
          createdAt: now.subtract(const Duration(hours: 2)),
        );
        await insertNotification(
          profileA.id!,
          'Tres',
          createdAt: now.subtract(const Duration(hours: 1)),
        );

        final clamped = await endpoints.notification.list(
          memberA,
          limit: 0,
          offset: 0,
        );
        expect(clamped, hasLength(1));
        expect(clamped.first.title, 'Tres');

        final negative = await endpoints.notification.list(
          memberA,
          limit: -10,
          offset: 0,
        );
        expect(negative, hasLength(1));
        expect(negative.first.title, 'Tres');

        final paged = await endpoints.notification.list(
          memberA,
          limit: 1,
          offset: 1,
        );
        expect(paged, hasLength(1));
        expect(paged.first.title, 'Dos');
      });
    });

    group('when counting unread notifications', () {
      test(
        'unreadCount only counts the unread notifications of the caller',
        () async {
          await insertNotification(
            profileA.id!,
            'Leída',
            readAt: DateTime.now().toUtc(),
          );
          await insertNotification(profileA.id!, 'No leída');
          await insertNotification(profileA.id!, 'Otra no leída');
          await insertNotification(profileB.id!, 'Ajena');

          expect(await endpoints.notification.unreadCount(memberA), 2);
          expect(await endpoints.notification.unreadCount(memberB), 1);
        },
      );
    });

    group('when marking a notification as read', () {
      test('ignores a notification of another member silently', () async {
        final foreign = await insertNotification(profileB.id!, 'Ajena');

        await endpoints.notification.markRead(memberA, foreign.id!);

        final refreshed = await AppNotification.db.findById(
          sessionBuilder.build(),
          foreign.id!,
        );
        expect(refreshed!.readAt, isNull);
      });

      test('marks an own notification as read', () async {
        final notification = await insertNotification(profileA.id!, 'Mía');

        await endpoints.notification.markRead(memberA, notification.id!);

        final refreshed = await AppNotification.db.findById(
          sessionBuilder.build(),
          notification.id!,
        );
        expect(refreshed!.readAt, isNotNull);
        expect(await endpoints.notification.unreadCount(memberA), 0);
      });
    });

    group('when marking all notifications as read', () {
      test('markAllRead zeroes the unread count of the caller only', () async {
        await insertNotification(profileA.id!, 'Uno');
        await insertNotification(profileA.id!, 'Dos');
        await insertNotification(profileB.id!, 'Ajena');

        await endpoints.notification.markAllRead(memberA);

        expect(await endpoints.notification.unreadCount(memberA), 0);
        expect(await endpoints.notification.unreadCount(memberB), 1);
      });

      test('markAllRead sets readAt on every unread notification', () async {
        final one = await insertNotification(profileA.id!, 'Uno');
        final two = await insertNotification(profileA.id!, 'Dos');
        final foreign = await insertNotification(profileB.id!, 'Ajena');

        await endpoints.notification.markAllRead(memberA);

        final refreshedOne = await AppNotification.db.findById(
          sessionBuilder.build(),
          one.id!,
        );
        final refreshedTwo = await AppNotification.db.findById(
          sessionBuilder.build(),
          two.id!,
        );
        expect(refreshedOne!.readAt, isNotNull);
        expect(refreshedTwo!.readAt, isNotNull);
        expect(await endpoints.notification.unreadCount(memberA), 0);

        final refreshedForeign = await AppNotification.db.findById(
          sessionBuilder.build(),
          foreign.id!,
        );
        expect(refreshedForeign!.readAt, isNull);
      });
    });
  });
}
