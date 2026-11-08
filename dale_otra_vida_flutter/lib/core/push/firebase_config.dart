import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Firebase project used only for push notifications. Fill these in from the
// Firebase console (Project settings → General → Your apps, and Cloud
// Messaging → Web Push certificates for the VAPID key), and mirror the web
// values in web/firebase-config.js. They are public identifiers, not
// secrets. While they are empty, push stays off and the app works as before.
const _projectId = '';
const _messagingSenderId = '';
const _webApiKey = '';
const _webAppId = '';
const _androidApiKey = '';
const _androidAppId = '';

/// Web Push certificate (public key) for FCM on the web.
const firebaseVapidKey = '';

/// Options for this platform, or null when push isn't set up for it.
FirebaseOptions? firebaseOptions() {
  if (_projectId.isEmpty) return null;
  if (kIsWeb) {
    if (_webAppId.isEmpty || firebaseVapidKey.isEmpty) return null;
    return const FirebaseOptions(
      apiKey: _webApiKey,
      appId: _webAppId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
    );
  }
  if (defaultTargetPlatform == TargetPlatform.android &&
      _androidAppId.isNotEmpty) {
    return const FirebaseOptions(
      apiKey: _androidApiKey,
      appId: _androidAppId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
    );
  }
  // iOS native push needs a paid Apple Developer account; iPhone users get
  // pushes through the installed web app instead.
  return null;
}
