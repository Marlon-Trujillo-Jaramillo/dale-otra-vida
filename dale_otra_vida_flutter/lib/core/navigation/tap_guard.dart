import 'dart:async';

import 'package:flutter/widgets.dart';

/// Ignores taps for a moment after a screen, dialog or sheet opens, so tapping
/// a message or button several times opens it once instead of stacking the
/// same screen five times.
class TapGuard extends NavigatorObserver {
  TapGuard({this.duration = const Duration(milliseconds: 500)});

  final Duration duration;
  final blocking = ValueNotifier(false);
  Timer? _timer;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // The first route of the app has nothing behind it to tap twice.
    if (previousRoute == null) return;
    blocking.value = true;
    _timer?.cancel();
    _timer = Timer(duration, () => blocking.value = false);
  }

  /// Wraps the whole app (MaterialApp.builder) to absorb taps while blocking.
  Widget wrap(Widget? child) => ValueListenableBuilder<bool>(
    valueListenable: blocking,
    builder: (context, absorbing, child) =>
        AbsorbPointer(absorbing: absorbing, child: child),
    child: child,
  );
}
