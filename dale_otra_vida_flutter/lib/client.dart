import 'dart:async';

import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/foundation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

// When you are running the app on a physical device, you need to set the
// server URL to the IP address of your computer. You can find the IP
// address by running `ipconfig` on Windows or `ifconfig` on Mac/Linux.
//
// You can set the variable when running or building your app like this:
// E.g. `flutter run --dart-define=SERVER_URL=https://api.example.com/`.
//
// Otherwise, the server URL is fetched from the assets/config.json file or
// defaults to http://$localhost:8080/ if not found.
final serverUrl = getServerUrl();

/// Sets up a global client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
/// In a larger app, you may want to use the dependency injection of your choice
/// instead of using a global client object. This is just a simple example.
late final Client client;

// Google OAuth client IDs (public identifiers, not secrets). The web client is
// the one the server verifies tokens against.
const _googleWebClientId =
    '135415936830-avmi1huhp4kt0cl0b6laovbtlqiaqpcq.apps.googleusercontent.com';
const _googleIosClientId =
    '135415936830-ph8cti0b40fvp45fu4ie0ngpb560qqe0.apps.googleusercontent.com';

Future<void> initializeClient() async {
  client = Client(await serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();
  unawaited(client.auth.initialize());

  if (!kIsWeb) {
    unawaited(
      client.auth.initializeGoogleSignIn(
        // Android identifies the app by package name + SHA-1 instead.
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? _googleIosClientId
            : null,
        serverClientId: _googleWebClientId,
      ),
    );
  }
}
