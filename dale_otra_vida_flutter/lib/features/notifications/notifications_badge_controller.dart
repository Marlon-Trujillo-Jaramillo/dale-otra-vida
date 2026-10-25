import 'dart:async';

import 'package:flutter/foundation.dart';

class NotificationsBadgeController extends ChangeNotifier {
  NotificationsBadgeController({
    this._fetchUnreadCount,
    this.pollInterval = const Duration(seconds: 30),
  });

  final Future<int> Function()? _fetchUnreadCount;
  final Duration pollInterval;

  int _count = 0;
  Timer? _timer;

  int get count => _count;

  String get label => _count > 9 ? '9+' : '$_count';

  bool get hasUnread => _count > 0;

  Future<void> refresh() async {
    final fetch = _fetchUnreadCount;
    if (fetch == null) return;

    try {
      _count = await fetch();
      notifyListeners();
    } catch (_) {
      // Keep the previous count on error.
    }
  }

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(pollInterval, (_) => refresh());
    refresh();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
