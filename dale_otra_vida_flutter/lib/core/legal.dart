import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Version of the data policy (web/privacidad.html). Must match
/// currentPrivacyVersion on the server; raise both when the policy changes so
/// every member accepts the new one.
const privacyVersion = 1;

/// The data policy, also served as a public page (Google's consent screen
/// links it too).
final privacyPolicyUrl = Uri.parse(
  'https://dale-otra-vida.serverpod.space/privacidad.html',
);

/// Where members exercise their data rights (Ley 1581).
const privacyContactEmail = 'tj.marlon0605@gmail.com';

/// Opens the policy without leaving the app: a separate tab or window on the
/// web (in the same window it would replace the app, and on an installed app
/// "back" then closes everything), an in-app browser on Android and iOS.
Future<void> openPrivacyPolicy() => launchUrl(
  privacyPolicyUrl,
  mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.inAppBrowserView,
  webOnlyWindowName: '_blank',
);

Future<void> emailPrivacyContact() => launchUrl(
  Uri(
    scheme: 'mailto',
    path: privacyContactEmail,
    query: 'subject=Mis datos en Dale Otra Vida',
  ),
);
