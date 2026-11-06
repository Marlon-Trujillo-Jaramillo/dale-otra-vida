import 'dart:io';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';
import 'package:serverpod_cloud_storage/serverpod_cloud_storage.dart';

import 'src/generated/serverpod.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod. The generated Serverpod class is already connected
  // with your project's generated code.
  final pod = Serverpod(args);

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Configure the email identity provider for email/password authentication.
      // The default setup works with Serverpod Cloud without configuration. In
      // development the verification codes are logged to the console, and in
      // staging and production they are sent through the Serverpod Cloud email
      // service. If you want to use a custom provider for sending emails, use
      // `EmailIdpConfigFromPasswords`.
      ServerpodCloudEmailIdpConfig(
        appDisplayName: 'Dale Otra Vida',
      ),
      // Reads `googleClientSecret` from config/passwords.yaml. A missing or
      // malformed secret turns Google sign-in off instead of crashing the
      // server.
      ?_googleIdpConfig(),
    ],
  );

  // Configure cloud storage.
  // This setup works with Serverpod Cloud without extra configuration.
  // If you want to use a custom provider for cloud storage, replace these
  // with your preferred provider.
  pod.addCloudStorage(
    await ServerpodCloudProvider.private(
      fallback: () => DatabaseCloudStorage('private'),
    ),
  );
  pod.addCloudStorage(
    await ServerpodCloudProvider.public(
      fallback: () => DatabaseCloudStorage('public'),
    ),
  );

  // Serve the Flutter web app that `serverpod run flutter_build` copies into
  // web/app (done before each Serverpod Cloud deploy). The build is plain
  // JS, so the WASM isolation headers are off; they would block the CDN
  // renderer and map tiles.
  final webApp = Directory('web/app');
  if (webApp.existsSync()) {
    pod.webServer.addRoute(FlutterRoute(webApp, enableWasmHeaders: false));
  }

  // Start the server.
  await pod.start();
}

GoogleIdpConfig? _googleIdpConfig() {
  try {
    return GoogleIdpConfigFromPasswords();
  } on Exception catch (e) {
    stderr.writeln('Google sign-in disabled: $e');
    return null;
  }
}
