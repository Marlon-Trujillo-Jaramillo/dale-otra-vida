import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../client.dart';
import 'firebase_config.dart';

/// What the member can do about push notifications on this device.
enum PushStatus {
  /// Not set up for this platform or browser (e.g. iPhone outside the
  /// installed app).
  unsupported,

  /// Supported, but the member hasn't been asked yet.
  available,

  /// The member blocked notifications for this app or site.
  denied,

  /// This device receives pushes.
  enabled,
}

/// Push notifications through Firebase Cloud Messaging. Everything is a
/// no-op until lib/core/push/firebase_config.dart is filled in.
class Push {
  Push._();

  static Future<bool>? _ready;
  static String? _token;
  static StreamSubscription<String>? _refresh;

  static String get _platform => kIsWeb
      ? 'web'
      : defaultTargetPlatform == TargetPlatform.iOS
      ? 'ios'
      : 'android';

  static Future<bool> _init() => _ready ??= () async {
    final options = firebaseOptions();
    if (options == null) return false;
    try {
      await Firebase.initializeApp(options: options);
      return await FirebaseMessaging.instance.isSupported();
    } catch (e) {
      debugPrint('Push unavailable: $e');
      return false;
    }
  }();

  static Future<PushStatus> status() async {
    if (!await _init()) return PushStatus.unsupported;
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return PushStatus.enabled;
      case AuthorizationStatus.denied:
      case AuthorizationStatus.deniedPermanently:
        return PushStatus.denied;
      case AuthorizationStatus.notDetermined:
        return PushStatus.available;
    }
  }

  /// Asks for permission and registers this device. On the web it must run
  /// from a tap (browsers ignore permission requests otherwise).
  static Future<PushStatus> enable() async {
    if (!await _init()) return PushStatus.unsupported;
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.deniedPermanently) {
      return PushStatus.denied;
    }
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      return PushStatus.available;
    }
    await _register();
    return PushStatus.enabled;
  }

  /// After sign-in: re-registers the device when permission was already
  /// given, since tokens change over time. Never asks.
  static Future<void> sync() async {
    try {
      if (await status() == PushStatus.enabled) await _register();
    } catch (e) {
      debugPrint('Push sync failed: $e');
    }
  }

  /// On sign-out: this device stops receiving the member's pushes.
  static Future<void> signOut() async {
    final token = _token;
    await _refresh?.cancel();
    _refresh = null;
    _token = null;
    if (token == null) return;
    try {
      await client.push.unregister(token);
      // ignore: deprecated_member_use
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('Push sign-out failed: $e');
    }
  }

  // getToken/onTokenRefresh are deprecated in favour of register/onRegistered,
  // which hand out installation IDs; the server sends through the HTTP v1
  // API with classic registration tokens, so this keeps the token flow.
  static Future<void> _register() async {
    // ignore: deprecated_member_use
    final token = await FirebaseMessaging.instance.getToken(
      vapidKey: kIsWeb ? firebaseVapidKey : null,
    );
    if (token == null) return;
    _token = token;
    await client.push.register(token, _platform);
    // ignore: deprecated_member_use
    _refresh ??= FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _token = token;
      unawaited(client.push.register(token, _platform));
    });
  }
}
