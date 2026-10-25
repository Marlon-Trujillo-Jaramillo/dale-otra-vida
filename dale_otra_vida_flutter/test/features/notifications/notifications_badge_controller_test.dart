import 'package:dale_otra_vida_flutter/features/notifications/notifications_badge_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationsBadgeController', () {
    test('fetch sets count and label', () async {
      var calls = 0;
      Future<int> fetch() async {
        calls++;
        return 3;
      }

      final controller = NotificationsBadgeController(
        fetchUnreadCount: fetch,
        pollInterval: const Duration(milliseconds: 100),
      );

      expect(controller.count, 0);
      expect(controller.hasUnread, false);

      controller.start();
      await Future.delayed(Duration.zero);

      expect(controller.count, 3);
      expect(controller.label, '3');
      expect(controller.hasUnread, true);
      expect(calls, 1);

      controller.dispose();
    });

    test('label shows "9+" for counts above 9', () async {
      Future<int> fetch() async => 12;

      final controller = NotificationsBadgeController(
        fetchUnreadCount: fetch,
        pollInterval: const Duration(milliseconds: 100),
      );

      controller.start();
      await Future.delayed(Duration.zero);

      expect(controller.label, '9+');

      controller.dispose();
    });

    test('dispose cancels the polling timer', () async {
      var calls = 0;
      Future<int> fetch() async {
        calls++;
        return 1;
      }

      final controller = NotificationsBadgeController(
        fetchUnreadCount: fetch,
        pollInterval: const Duration(milliseconds: 50),
      );

      controller.start();
      await Future.delayed(Duration.zero);
      final callsAfterStart = calls;

      controller.dispose();
      await Future.delayed(const Duration(milliseconds: 200));

      expect(calls, callsAfterStart);
    });

    test('refresh fetches count again', () async {
      var count = 1;
      Future<int> fetch() async => count++;

      final controller = NotificationsBadgeController(
        fetchUnreadCount: fetch,
        pollInterval: const Duration(minutes: 1),
      );

      await controller.refresh();
      expect(controller.count, 1);

      await controller.refresh();
      expect(controller.count, 2);

      controller.dispose();
    });
  });
}
