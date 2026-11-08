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

  Future<void>? _inFlight;
  bool _again = false;

  /// Fetches the count. Calls that arrive while one is running share it and
  /// trigger at most one more fetch afterwards, so bursts (several messages,
  /// a chat being read, returning to a tab) don't duplicate requests.
  Future<void> refresh() {
    if (_fetchUnreadCount == null) return Future.value();
    if (_inFlight != null) {
      _again = true;
      return _inFlight!;
    }
    return _inFlight = _fetch().whenComplete(() {
      _inFlight = null;
      if (_again) {
        _again = false;
        refresh();
      }
    });
  }

  Future<void> _fetch() async {
    try {
      _count = await _fetchUnreadCount!();
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
